USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[AUDIT_LOG_DATE_WISE]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Executed the sp for Ca.Sg Audit Log Between jan 1st,2020 to jan 31,2020 on 04-03-2020
--Exec AUDIT_LOG_DATE_WISE Null,'2020-01-01','2020-01-31',459
Create   Procedure [Common].[AUDIT_LOG_DATE_WISE]
@UserName Nvarchar(2000),
@StartDate DateTime2,
@EndDate DateTime2,
@CompanyId BigInt
As
Begin
Declare @Count Int
Declare @Comma Char(1)
Declare @RecCount Int
Declare @TableName Nvarchar(250)
Declare @Created Nvarchar(20)
Declare @Modified Nvarchar(20)
Declare @ExceSQL Nvarchar(4000)
Declare @AuditTrailDetls Table (TableName Nvarchar(250),UserName Nvarchar(250),ActionType Nvarchar(50),ActionDate Datetime2(7),CompanyId BigInt)
Declare @TableNames_Temp  Table (S_No Int Identity(1,1),TableName Nvarchar(250))
    Set @Modified='Modified'
    Set @Created='Created'
    Insert Into @TableNames_Temp
    Select Tablename From Primary_TableNames
    Set @Count=(Select Count(*) From Primary_TableNames)
    Set @RecCount=1
    Set @Comma=','
    While @Count>=@RecCount
    Begin
        Set @TableName=(Select TableName From @TableNames_Temp Where S_No=@recCount)
        IF Exists (Select Concat(TABLE_SCHEMA,'.',TABLE_NAME) From INFORMATION_SCHEMA.COLUMNS Where column_name = 'UserCreated' And Concat(TABLE_SCHEMA,'.',TABLE_NAME)=@TableName)
        Begin
            IF @TableName = 'HR.EmployeePayrollSetting' Or @TableName='HR.Payroll'
            Begin
                IF @UserName Is Not Null
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreateDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And UserCreated In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And CreateDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
                Else
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreateDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And CreateDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
            End
            Else
            Begin
                IF @UserName Is Not Null
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreatedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And UserCreated In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And CreatedDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
                Else
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreatedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And CreatedDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
            End
            Insert Into @AuditTrailDetls
            Exec (@ExceSQL)
        End
        IF Exists (Select Concat(TABLE_SCHEMA,'.',TABLE_NAME) From INFORMATION_SCHEMA.COLUMNS Where column_name = 'ModifiedBy' And Concat(TABLE_SCHEMA,'.',TABLE_NAME)=@TableName)
        Begin
            IF @UserName IS Not Null
            Begin
                Set @ExceSQL='Select '''+ @TableName +''',ModifiedBy,'''+@Modified+''', ModifiedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And ModifiedBy Is Not Null And ModifiedBy In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And ModifiedDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
            End
            Else
            Begin
                Set @ExceSQL='Select '''+ @TableName +''',ModifiedBy,'''+@Modified+''', ModifiedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And ModifiedDate Between '''+Cast(@StartDate As Nvarchar(1000))+''' And '''+Cast(@EndDate As Nvarchar(1000))+''' '
            End
            Print @ExceSQL
            Insert Into @AuditTrailDetls
            Exec (@ExceSQL)
        End
        Set @RecCount=@RecCount+1
    End
	Select ActionDate As [Date],PT.CursorName As [Application],PT.Feature As Feature,ADT.TableName As TableNameWithSchema,ADT.UserName As [User],
				ActionType As [Action],ADT.CompanyId,
				STUFF(
						(
						Select ',' + Username from Common.CompanyUser As CU1
						Where CU1.FirstName=ADT.UserName And CU1.CompanyId=ADT.CompanyId
						for xml path('')
						),1,1,''
					)
		From @AuditTrailDetls As ADT
		Inner Join Primary_TableNames As PT On ADT.TableName=PT.TableName
		Inner Join (select Firstname,Companyid,
							stuff((
									select ',' + CU1.FirstName
									from Common.CompanyUser CU1
									where CU1.FirstName = CU.Firstname
									order by CU1.FirstName
									for xml path('')
								),1,1,'') as UserName
	from Common.CompanyUser As CU group by FirstName,Companyid) As Usr On Usr.FirstName=ADT.UserName And Usr.Companyid=ADT.Companyid
    --Order By ADT.TableName,ADT.UserName,ActionDate Desc
	where ADT.UserName is not null and ADT.[UserName] != 'System'
    Order By ADT.TableName,ADT.UserName,ActionDate Desc
End




   
GO

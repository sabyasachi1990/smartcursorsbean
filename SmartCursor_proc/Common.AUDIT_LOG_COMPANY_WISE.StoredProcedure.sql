USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[AUDIT_LOG_COMPANY_WISE]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [Loading_Query_AuditLog_Sp] Null,'2020-01-25',619
CREATE Procedure [Common].[AUDIT_LOG_COMPANY_WISE]
@UserName Nvarchar(2000),
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
Declare @CompanyName Nvarchar(264)
Set @CompanyName=(Select Name From Common.Company Where Id=@CompanyId)
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
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreateDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And UserCreated In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And CreateDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
                Else
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreateDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And CreateDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
            End
            Else
            Begin
                IF @UserName Is Not Null
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreatedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And UserCreated In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And CreatedDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
                Else
                Begin
                    Set @ExceSQL='Select '''+ @TableName +''',UserCreated,'''+@Created+''', CreatedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And CreatedDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
                End
            End
            Insert Into @AuditTrailDetls
            Exec (@ExceSQL)
        End
        IF Exists (Select Concat(TABLE_SCHEMA,'.',TABLE_NAME) From INFORMATION_SCHEMA.COLUMNS Where column_name = 'ModifiedBy' And Concat(TABLE_SCHEMA,'.',TABLE_NAME)=@TableName)
        Begin
            IF @UserName IS Not Null
            Begin
                Set @ExceSQL='Select '''+ @TableName +''',ModifiedBy,'''+@Modified+''', ModifiedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And ModifiedBy Is Not Null And ModifiedBy In (Select items From SplitToTable('''+@UserName+''','''+@Comma+''')) And ModifiedDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
            End
            Else
            Begin
                Set @ExceSQL='Select '''+ @TableName +''',ModifiedBy,'''+@Modified+''', ModifiedDate,Companyid From '+@TableName+' Where Companyid='''+Cast(@CompanyId As Nvarchar(50))+''' And ModifiedDate <= '''+Cast(@EndDate As Nvarchar(1000))+''' '
            End
            Insert Into @AuditTrailDetls
            Exec (@ExceSQL)
        End
        Set @RecCount=@RecCount+1
    End
    Insert into SmartCursorAuditLogs.Common.AuditLogs ([Application],Feature,[User],[Action],[Date],[CompanyName],[CompanyId],DataUpTo)
    Select PT.CursorName As [Application],PT.Feature As Feature,UserName As [User],ActionType As [Action],ActionDate As [Date],@CompanyName As CompanyName,@CompanyId As CompanyId,@EndDate AS DateUpTo
    From @AuditTrailDetls As ADT
    Inner Join Primary_TableNames As PT On ADT.TableName=PT.TableName
    Order By ADT.TableName,UserName,ActionDate Desc
End


















GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[GL_ExcelData_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [dbo].[GL_ExcelData_New] 'F:\Analytics\GL1.xlsx','6a2d20cf-2685-4bf3-afe5-0f2a2054793d',1,'dtn'

CREATE Procedure [dbo].[GL_ExcelData_New] 

@FilePath Nvarchar(255),
@EngagementId Uniqueidentifier,
@CompanyId BigInt,
@Type Nvarchar(50)
As
Begin

 EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
 EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
 --///CONFIGURING SQL INSTANCE TO ACCEPT ADVANCED OPTIONS
 EXEC sp_configure 'show advanced options', 1
 RECONFIGURE
--////ENABLING USE OF DISTRIBUTED QUERIES
 EXEC sp_configure 'Ad Hoc Distributed Queries', 1
 RECONFIGURE  

 Declare @GlTemp_Tbl Table (S_No Int Identity(1,1),[Date] [nvarchar](255),Type [nvarchar](255),[SubType] [nvarchar](255),[DocNo] [nvarchar](50),
                     [Entity] [nvarchar](255),[Description] [nvarchar](500),[Curr] [nvarchar](20),[Debit] Float,[Credit] Float,[Balance] Float)
 Declare @RecData Nvarchar(Max)
 --Drop Table Audit.GLExcel_Data
 --////Insert Into @GlTemp_Tbl
 Set @RecData = 'Select * FROM OPENROWSET (''Microsoft.ACE.OLEDB.12.0'',
                      ''Excel 12.0 XML;Database=' +@Filepath+ ';HDR=YES;IMEX=1'', 
                      ''SELECT Date,Type,SubType,DocNo,Entity,Description,Currency,Debit,Credit,Balance FROM [sheet1$]'')'

Begin
 Insert Into @GlTemp_Tbl
 Exec(@RecData)
 End
 --Begin
 -- Insert Into [FinanceDWH].[dbo].[DimDocument] ([DocumentId],[DocumentNo],[DocumentDesc],[CompanyId])
	--	Select NEWID(),DocNo,Description,@CompanyId from @GlTemp_Tbl  group by DocNo,Description,@CompanyId
 --End
--Begin Transaction
--Begin Try
Declare @SNo Int,
		@Date Nvarchar(255),
		@AccountName Nvarchar(255),
		@AccountNumber Nvarchar(50),
		@PrevAccount Nvarchar(255),
		@BF_Description Nvarchar(255),
		@BF_Balance Decimal(17,2),
		@ClosingBal Decimal(17,2),
		@Next_Sno Int,
		@recorder Int=0,
		@Sno_OPB Int
		--@DocNo Nvarchar(50),
		--@Currency Nvarchar(20)
--// Declare Cursor to get Account Names
Declare GLDataCsr Cursor For
	Select S_No,[Date] from @GlTemp_Tbl Where [Date] Is Not Null And [Type] is null And [SubType] Is null And [DocNo] Is Null And [Entity] Is null
										And [Description] Is Null And [Curr] Is null And [Debit] Is Null And [Credit] Is Null And Balance Is Null Order By S_No
	Open GLDataCsr
	Fetch Next From GLDataCsr Into @SNo,@Date
	While @@FETCH_STATUS=0
	Begin --// Cursor 1
	
	--// Get next serial number to get records between accounts	
		Select @Next_Sno=Min(S_No) from @GlTemp_Tbl Where [Date] Is Not Null And [Type] is null And [SubType] Is null And [DocNo] Is Null And [Entity] Is null
											And [Description] Is Null And [Curr] Is null And [Debit] Is Null And [Credit] Is Null And Balance Is Null
											And S_No >@SNo
	--// Next serial number is null [when no records are there] take max serial number
		--If @Next_Sno Is null
		--Set @Next_Sno=(Select MAX(S_No) from @GlTemp_Tbl)
		Declare @Max_Sno bigint=(Select MAX(S_No) from @GlTemp_Tbl)
	--// Split AccountNumber And AccountName
		If CHARINDEX('-',@Date)=0
		Begin
			Set @AccountName=@Date
		End
		Else 
		Begin
			Set @AccountName=Ltrim(substring(@Date,1,CHARINDEX('-',@Date)-1))
			Set @AccountNumber=substring(@Date,CHARINDEX('-',@Date)+1,DATALENGTH(@Date))
		End
	--// Get balance brought forward amount of Account Name
		Set @recorder=@recorder+1
		--@Sno_OPB=S_No,
		--Select @BF_Description=Description,@BF_Balance=Convert (Decimal(17,2),coalesce(Debit,Credit)) From @GlTemp_Tbl Where S_No Between @SNo And Coalesce(@Next_Sno,@Max_Sno)  --And Date=@Date 
		--	 And Rtrim(Ltrim([Description])) in ('Balance b/f','BF','Op.Bal','Opening Balance','Opening Bal','Balance B/f','Bal B/f','Bal. brought forward','Balance brought forward')
		Set @BF_Balance=0
			 --print(@AccountName)

    
	--	Select @ClosingBal=(Convert(Decimal(17,2),SUM(Isnull(Debit,0)-Isnull(Credit,0)))) From @GlTemp_Tbl Where
		-- S_No Between @SNo+1 And (Case When @Next_Sno is not null Then @Next_Sno-2 Else @Max_Sno-1 End) And Date is not null

		 --print(@AccountName+'Done')

		IF Not Exists(Select * From Audit.GeneralLedgerImport Where AccountName=@AccountName And EngagementId=@EngagementId And GLType=@Type)
		Begin
			Declare @NewId_Import uniqueidentifier=Newid()
			--Declare @NewId uniqueidentifier=Newid()
			
			Insert Into Audit.GeneralLedgerImport(Id,EngagementId,CompanyId,AccountNumber,AccountName,Openingbalance,
			ClosingBalance,createdDate,	RecOrder,GLType,CYorPYBalance)
				Values(@NewId_Import,@EngagementId,@CompanyId,Rtrim(Ltrim(@AccountNumber)),Rtrim(Ltrim(@AccountName)),@BF_Balance,@ClosingBal,GETDATE(),@recorder,@Type,@ClosingBal)
	
			Insert Into Audit.GeneralLedgerDetail(Id,GeneralLedgerId,Description,Gldate,Debit,credit,Balance,recOrder,DocNo,Currency)
				Select NEWID(),@NewId_Import,Rtrim(Ltrim([Description])),convert(datetime, date,103),Convert(Decimal(17,2),Debit),Convert(Decimal(17,2),Credit),
				convert(Decimal(17,2),Balance),0,[DocNo],[Curr] From @GlTemp_Tbl Where S_No Between @SNo+1 And (Case When @Next_Sno is not null Then @Next_Sno-2 Else @Max_Sno-1 End)
				
				--And S_No <> @Sno_OPB

				--set @ClosingBal= (select SUM (Debit-Credit)  from Audit.GeneralLedgerDetail where GeneralLedgerId=@NewId_Import)

				--set @ClosingBal=@ClosingBal+@BF_Balance;

				 update Audit.GeneralLedgerImport set ClosingBalance= (select SUM(Isnull(Debit,0)-Isnull(Credit,0))  from Audit.GeneralLedgerDetail where GeneralLedgerId=@NewId_Import) Where Id=@NewId_Import

				
		End
		Fetch Next From GLDataCsr Into @SNo,@Date
	End  --// Cursor 1
	Close GLDataCsr
	Deallocate GLDataCsr
--COMMIT TRANSACTION
--End Try
--Begin Catch

--ROLLBACK TRANSACTION
--SELECT   
--        ERROR_NUMBER() AS ErrorNumber,
--		ERROR_MESSAGE() AS ErrorMessage;
--End Catch
End



	
GO

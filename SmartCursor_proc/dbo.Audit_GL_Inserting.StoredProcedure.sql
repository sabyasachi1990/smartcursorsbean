USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_GL_Inserting]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Audit_GL_Inserting 'a5b9d479-bb4a-47c1-809a-f49e2f702f06',771,1
CREATE Procedure [dbo].[Audit_GL_Inserting]
@EngagementId Uniqueidentifier,
@CompanyId BigInt,
@IsOverRide Int,
@GlType Nvarchar(50)
As
Begin
	Declare @AccountName Nvarchar(500)
	Declare @RecOrder Int
	Declare @Count Int
	Declare @RecCount Int
	Declare @Status Int 
	Declare @NextRecOrder Int
	Declare @User Nvarchar(50)
	Declare @GetDate datetime2(7)
	Declare @GeneralLedgerId Uniqueidentifier
	Declare @ErrMsg Nvarchar(4000)
	Declare @OpenBal Decimal(17,2)
	Declare @TotalAmtRecOrder int
	Declare @TotalDesc Nvarchar(512)

	Declare @AccountNameDtl Table (S_No Int Identity (1,1),AccountName Nvarchar(500),RecOrder Int)
	Begin Transaction
	Begin Try
		Set @GetDate=GETUTCDATE()
		Set @Status=1
		Set @User='System'
		IF @IsOverRide=1
		Begin
		
			-- Check and delte if data exist with same engagement id
			IF Exists (Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId)
			Begin
				Delete From Audit.GeneralLedgerDetail Where GeneralLedgerId In (Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType)
				Delete From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType
			End
			Insert Into @AccountNameDtl (AccountName,RecOrder)
			Select RTrim(LTrim(AccountName)),Recorder from Import.ImportGl 
			Where engagementid=@EngagementId And AccountName Is Not Null And AccountName <>'' And AccountName Not Like '%Total %'
					And (Date Is Null Or Date='') And (Type Is null Or Type ='') And (SubType Is null Or SubType ='') And (Entity Is null Or Entity ='')
					And (Description Is null Or Description ='') And (Source Is null Or Source ='') And (DocNo Is null Or DocNo ='') And (Currency Is null Or Currency ='')
					And (Amount Is null Or Amount ='') And (Debit Is null Or Debit ='') And (Credit Is null Or Credit ='')-- And (Balance Is null Or Balance ='')
					Order by Recorder
		 
	
			Set @Count=(Select Count(*) From @AccountNameDtl)
			Set @RecCount=1
			While @Count>=@RecCount
			Begin
				Set @AccountName=(Select AccountName From @AccountNameDtl Where S_No=@RecCount)
				Set @TotalDesc=Concat('Total ',@AccountName);
				Set @RecOrder=(Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				Set @GeneralLedgerId=NEWID()
				Insert into Audit.GeneralLedgerImport (Id,EngagementId,CompanyId,AccountName,OpeningBalance,RecOrder,UserCreated,CreatedDate,Status,GLType)
					Select @GeneralLedgerId,EngagementId,@CompanyId,RTrim(LTrim(AccountName)),Case When Balance Is not Null And Balance<>'' Then CAST(Balance As Decimal(17,2)) Else Null End As OpenBal,Recorder,@User,@GetDate,@Status,GLType From Import.ImportGl Where EngagementId=@EngagementId And Recorder=@RecOrder And RTrim(LTrim(AccountName))=@AccountName
				Set @RecCount=@RecCount+1
				IF Exists (Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				Begin
					Set @NextRecOrder=(Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				End
				Else
				Begin
					Set @NextRecOrder=(Select Max(RecOrder) From Import.ImportGl Where EngagementId=@EngagementId)
				End
				Insert Into Audit.GeneralLedgerDetail (Id,GeneralLedgerId,Description,GLDate,Debit,Credit,Balance,EntityType,RecOrder,DocNo,Currency)
					Select NEWID(),@GeneralLedgerId,[Description],Case When [Date]='' Then Null Else CONVERT(datetime2(7),Date,103)/*CAST([Date] As datetime2(7))*/ End As GLDate,
							Case When Debit Is Not Null And Debit='' Then
										Case When (Credit Is Not Null And Credit='') And (Amount IS Not Null And Amount<>'') Then 
											Case When Cast(Amount As decimal(17,2)) >=0 Then Cast(Amount As decimal(17,2)) End
										End
								 Else Cast(Debit As decimal(17,2)) End,
							Case When Credit Is Not Null And Credit='' Then
										Case When (Debit Is Not Null And Debit='') And (Amount IS Not Null And Amount<>'') Then 
											Case When Cast(Amount As decimal(17,2)) <0 Then Abs(Cast(Amount As decimal(17,2))) End
										End
								 Else Cast(Credit As decimal(17,2)) End,
							Case When Balance='' Then Null Else CAST(Balance As decimal(17,2)) End,
							[Type],Recorder,DocNo,Currency 
					From Import.ImportGl 
					Where EngagementId=@EngagementId And Date Is Not Null And Date <>'' 
							And Type <> 'Net movement' 
							And Description Not Like '%'+@TotalDesc+'%'						
							And Recorder>@RecOrder And Recorder< @NextRecOrder
							And Recorder Not In (Select Recorder From Import.ImportGl Where Recorder>@RecOrder And Recorder< @NextRecOrder And Type Like '%Total %')
							And Recorder Not In (Select Recorder From Import.ImportGl Where Recorder>@RecOrder And Recorder< @NextRecOrder And AccountName Like '%Total %')
					Order By Recorder
			update Audit.GeneralLedgerImport set ClosingBalance= OpeningBalance +(select SUM(ISNULL(Debit,0))-Sum(ISNULL(Credit,0))  from Audit.GeneralLedgerDetail where Description not like '%Total%'   and GeneralLedgerId=@GeneralLedgerId) Where Id=@GeneralLedgerId
			End
		End
		Else
		Begin
			Insert Into @AccountNameDtl (AccountName,RecOrder)
			Select RTrim(LTrim(AccountName)),Recorder from Import.ImportGl 
			Where engagementid=@EngagementId And AccountName Is Not Null And AccountName <>'' And AccountName Not Like '%Total %'
					And (Date Is Null Or Date='') And (Type Is null Or Type ='') And (SubType Is null Or SubType ='') And (Entity Is null Or Entity ='')
					And (Description Is null Or Description ='') And (Source Is null Or Source ='') And (DocNo Is null Or DocNo ='') And (Currency Is null Or Currency ='')
					And (Amount Is null Or Amount ='') And (Debit Is null Or Debit ='') And (Credit Is null Or Credit ='') And (Balance Is null Or Balance ='')
					Order by Recorder
			Set @Count=(Select Count(*) From @AccountNameDtl)
			Set @RecCount=1
			While @Count>=@RecCount
			Begin
				Set @AccountName=(Select AccountName From @AccountNameDtl Where S_No=@RecCount)
				Set @TotalDesc=Concat('Total ',@AccountName);
				Set @RecOrder=(Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				IF Exists(Select Id From Audit.GeneralLedgerImport Where AccountName=@AccountName And EngagementId=@EngagementId)
				Begin
					Update GLI Set GLI.CompanyId=@CompanyId,GLI.OpeningBalance=Case When IG.Balance Is not Null And IG.Balance<>'' Then CAST(IG.Balance As Decimal(17,2)) Else Null End,
									GLI.RecOrder=IG.Recorder,GLI.ModifiedDate=@GetDate,GLI.UserCreated=@User					
					From Audit.GeneralLedgerImport As GLI 
					Inner Join Import.ImportGl As IG On GLI.AccountName=RTrim(LTrim(IG.AccountName)) And GLI.EngagementId=IG.EngagementId 
					Where GLI.EngagementId=@EngagementId And IG.Recorder=@RecOrder And RTrim(LTrim(IG.AccountName))=@AccountName
					Set @GeneralLedgerId=(Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId And AccountName=@AccountName)
					Delete From Audit.GeneralLedgerDetail Where GeneralLedgerId=@GeneralLedgerId
				End
				Else
				Begin
					Set @GeneralLedgerId=NEWID()
					Insert into Audit.GeneralLedgerImport (Id,EngagementId,CompanyId,AccountName,OpeningBalance,RecOrder,UserCreated,CreatedDate,Status,GLType)
						Select @GeneralLedgerId,EngagementId,@CompanyId,RTrim(LTrim(AccountName)),Case When Balance Is not Null And Balance<>'' Then CAST(Balance As Decimal(17,2)) Else Null End As OpenBal,Recorder,@User,@GetDate,@Status,GLType From Import.ImportGl Where EngagementId=@EngagementId And Recorder=@RecOrder And RTrim(Ltrim(AccountName))=@AccountName
				End
				Set @RecCount=@RecCount+1
				IF Exists (Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				Begin
					Set @NextRecOrder=(Select RecOrder From @AccountNameDtl Where S_No=@RecCount)
				End
				Else
				Begin
					Set @NextRecOrder=(Select Max(RecOrder) From Import.ImportGl Where EngagementId=@EngagementId)
				End
				
				Insert Into Audit.GeneralLedgerDetail (Id,GeneralLedgerId,Description,GLDate,Debit,Credit,Balance,EntityType,RecOrder,DocNo,Currency)
					Select NEWID(),@GeneralLedgerId,[Description],Case When [Date]='' Then Null Else CONVERT(datetime2(7),Date,103)/*CAST([Date] As datetime2(7))*/ End As GLDate,
							Case When Debit Is Not Null And Debit='' Then
										Case When (Credit Is Not Null And Credit='') And (Amount IS Not Null And Amount<>'') Then 
											Case When Cast(Amount As decimal(17,2)) >=0 Then Cast(Amount As decimal(17,2)) End
										End
								 Else Cast(Debit As decimal(17,2)) End,
							Case When Credit Is Not Null And Credit='' Then
										Case When (Debit Is Not Null And Debit='') And (Amount IS Not Null And Amount<>'') Then 
											Case When Cast(Amount As decimal(17,2)) <0 Then Abs(Cast(Amount As decimal(17,2))) End
										End
								 Else Cast(Credit As decimal(17,2)) End,
							Case When Balance='' Then Null Else CAST(Balance As decimal(17,2)) End,
							[Type],Recorder,DocNo,Currency 
					From Import.ImportGl 
					Where EngagementId=@EngagementId And Date Is Not Null And Date <>'' 
							And Type <> 'Net movement'
							And Description Not Like '%'+@TotalDesc+'%'
							And Recorder>@RecOrder And Recorder< @NextRecOrder
							And Recorder Not In (Select Recorder From Import.ImportGl Where Recorder>@RecOrder And Recorder< @NextRecOrder And Type Like '%Total %')
							And Recorder Not In (Select Recorder From Import.ImportGl Where Recorder>@RecOrder And Recorder< @NextRecOrder And AccountName Like '%Total %')

					Order By Recorder
			 update Audit.GeneralLedgerImport set ClosingBalance= OpeningBalance +(select SUM(ISNULL(Debit,0))-Sum(ISNULL(Credit,0))  from Audit.GeneralLedgerDetail where Description not like '%Total%'   and GeneralLedgerId=@GeneralLedgerId) Where Id=@GeneralLedgerId
			End
		End
		Truncate Table Import.ImportGl
		Update AUDIT.AUDITCOMPANYENGAGEMENT set GLStatus='Completed' where id=@EngagementId
		Commit Transaction
	End try
	Begin Catch
		Rollback transaction
		Set @ErrMsg=(Select ERROR_MESSAGE())
		RaisError(@ErrMsg,16,1)
	End Catch

End


 
GO

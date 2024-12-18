USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_BRC_Re_Run]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   procedure [dbo].[Bean_Update_BRC_Re_Run] 
(
@CompanyId BigInt,
@OldServEntityId BigInt null,
@NewServEntityId BigInt null,
@OldCoaId BigInt null,
@NewCoaId BigInt null,
@OldDocdate DateTime null,
@NewDocDate DateTime null,
@OldDocAmount Money null,
@NewDocAmount Money null,
@IsAdd bit
)
AS
Begin 
	Begin Try
		If Exists(Select Id from Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and COAId in (@OldCoaId,@NewCoaId) and ServiceCompanyId in (@OldServEntityId,@NewServEntityId) and State='Reconciled')
		Begin

			If(@IsAdd=1)
			Begin
        
				--IF Exists(Select Id from Bean.BankReconciliation where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId)
				--Begin
				--    Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId and BankReconciliationDate>=@NewDocDate and State='Reconciled'
				--End
				IF Exists(Select id From Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId)
				Begin
					Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId and        BankReconciliationDate>=@OldDocdate and State='Reconciled'
				End
			End
			Else
			Begin
				If(@OldServEntityId!=@NewServEntityId and @OldCoaId!=@NewCoaId)
				Begin
					IF Exists(Select Id from Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId and        BankReconciliationDate>=@NewDocDate and State='Reconciled'
					End
					IF Exists(Select id From Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId and            BankReconciliationDate>=@OldDocdate and State='Reconciled'
					End
				End
				Else If(@OldServEntityId=@NewServEntityId and @OldCoaId=@NewCoaId and @OldDocAmount!=@NewDocAmount)
				Begin
					IF Exists(Select Id from Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId and        BankReconciliationDate>=@NewDocDate and State='Reconciled'
					End
					IF Exists(Select id From Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId and            BankReconciliationDate>=@OldDocdate and State='Reconciled'
					End
				End
				Else If(@OldServEntityId=@NewServEntityId and @OldCoaId=@NewCoaId and @OldDocdate!=@NewDocDate)
				Begin
					IF Exists(Select Id from Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@NewServEntityId and COAId=@NewCoaId and        BankReconciliationDate>=@NewDocDate and State='Reconciled'
					End
					IF Exists(Select id From Bean.BankReconciliation(Nolock) where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId)
					Begin
						Update Bean.BankReconciliation set IsReRunBR=1 where CompanyId=@CompanyId and ServiceCompanyId=@OldServEntityId and COAId=@OldCoaId and            BankReconciliationDate>=@OldDocdate and State='Reconciled'
					End
				End

 

			End

		End
	End Try
	Begin Catch
	End Catch
End
GO

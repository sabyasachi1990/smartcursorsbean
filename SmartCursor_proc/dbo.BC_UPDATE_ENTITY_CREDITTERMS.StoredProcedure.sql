USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_UPDATE_ENTITY_CREDITTERMS]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BC_UPDATE_ENTITY_CREDITTERMS]
@EntityId UNIQUEIDENTIFIER,
@BaseAmount Decimal,
@DocType NVARCHAR(50),
@CompanyId INT,
@isEdit bit,
@isVoid bit
As
Begin
	Set @isEdit=@isEdit
	set @isVoid=@isVoid
	If Exists(Select Id from Bean.Entity where Id=@EntityId AND CompanyId=@CompanyId and IsCustomer=1 and CustCreditLimit!=null)
	Begin
		if(@isVoid=0)
		Begin
			if(@isEdit=0)
			Begin
				Set @BaseAmount = Case When  @DocType = 'Invoice' Or @DocType = 'Debit Note'  Then -@BaseAmount Else @BaseAmount END
				Update Bean.Entity Set CreditLimitValue=CreditLimitValue+@BaseAmount where Id=@EntityId AND CompanyId=@CompanyId
			End
			else
			Begin
				Update Bean.Entity Set CreditLimitValue=@BaseAmount  where Id=@EntityId AND CompanyId=@CompanyId
			End
		End
		else
		Begin
		Set @BaseAmount = Case When  @DocType = 'Invoice' Or @DocType = 'Debit Note'  Then @BaseAmount Else -@BaseAmount END
			Update Bean.Entity Set CreditLimitValue=CreditLimitValue+@BaseAmount where Id=@EntityId AND CompanyId=@CompanyId
		End
	End
END
GO

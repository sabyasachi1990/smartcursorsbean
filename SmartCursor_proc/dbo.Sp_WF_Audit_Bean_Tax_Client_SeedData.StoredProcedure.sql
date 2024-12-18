USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Audit_Bean_Tax_Client_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------------------------------------
--[Common].[TermsOfPayment]  WF ,Audit,Bean,tax ,Client
CREATE Procedure [dbo].[Sp_WF_Audit_Bean_Tax_Client_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT,@STATUS BIGINT)
As
Begin
DECLARE @CREATED_DATE DATETIME	
SET @CREATED_DATE =GETUTCDATE()
Declare @TermsOfPayment_Cnt int
Select @TermsOfPayment_Cnt = count(*) from [Common].[TermsOfPayment] where CompanyId = @NEW_COMPANY_ID
If @TermsOfPayment_Cnt =0
Begin
------------------------------------------------------TERMS OF PAYMENT  ------------------------------------------------------------------------
		INSERT INTO [Common].[TermsOfPayment] (Id, Name, CompanyId, TermsType, TOPValue, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, 
			ModifiedDate, Version, Status, IsVendor, IsCustomer)
			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[TermsOfPayment] ), Name, @NEW_COMPANY_ID, TermsType, TOPValue, 
			RecOrder, Remarks, UserCreated, @CREATED_DATE, null, null, Version, status, IsVendor, IsCustomer FROM [Common].[TermsOfPayment] 
			WHERE COMPANYID=@UNIQUE_COMPANY_ID;
			End
End 
GO

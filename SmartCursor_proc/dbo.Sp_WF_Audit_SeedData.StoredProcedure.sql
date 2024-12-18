USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Audit_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Sp_WF_Audit_SeedData](@NEW_COMPANY_ID BIGINT)
As
Begin
-------------------------------------------------------------------------ACCOUNT TYPE ID TYPE----------------------------------------------------------
		INSERT INTO  [Common].[AccountTypeIdType] (Id, AccountTypeId, IdTypeId, RecOrder)		
			SELECT ROW_NUMBER() OVER(ORDER BY A.ID) + (SELECT MAX(ID) + 1 FROM [Common].[AccountTypeIdType]) ,B.Id AS ACCOUNTTYPEID,C.Id AS IDTYPEID,
			A.RecOrder FROM [Common].[AccountTypeIdType] A JOIN [Common].[AccountType] B ON A.AccountTypeId = B.TempAccountTypeId JOIN [Common].[IdType] C 
			ON C.TempIdTypeId = A.IdTypeId	WHERE B.CompanyId=@NEW_COMPANY_ID AND C.CompanyId=@NEW_COMPANY_ID;


End 
GO

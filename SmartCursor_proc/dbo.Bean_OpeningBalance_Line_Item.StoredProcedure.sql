USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_OpeningBalance_Line_Item]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create proc [dbo].[Bean_OpeningBalance_Line_Item]
@COAId BIGINT,
@ServiceCompanyId BIGINT,
@Currency NVARCHAR(100),
@CompanyId BIGINT,
@detailId Uniqueidentifier
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)

	BEGIN TRY
	BEGIN TRANSACTION
		Select OB.[Date],OB.BaseCurrency,OB.Id,
                OB.OpeningBalanceDetailId,
                OB.COAId,
                COA.Name,
                COA.Code,
                OB.BaseCredit,
                OB.BaseDebit ,
                OB.DocumentCurrency ,
                OB.DocCredit ,
                OB.DocDebit ,
                OB.[Description],
                OB.ExchangeRate,
                OB.EntityId,
                OB.ServiceCompanyId,
                OB.DocumentReference,
                OB.IsDisAllow ,OB.UserCreated,OB.CreatedDate,OB.ModifiedBy ,OB.ModifiedDate,OB.DueDate,OB.IsEditable,OB.RecOrder,OB.IsProcressed,OB.ProcressedRemarks from Bean.OpeningBalanceDetailLineItem OB
		JOIN Bean.ChartOfAccount COA ON OB.COAId = COA.Id
		WHERE OB.ServiceCompanyId = @ServiceCompanyId AND COA.CompanyId =@CompanyId AND OB.DocumentCurrency = @Currency AND OB.COAId = @COAId AND OB.OpeningBalanceDetailId = @detailId
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO

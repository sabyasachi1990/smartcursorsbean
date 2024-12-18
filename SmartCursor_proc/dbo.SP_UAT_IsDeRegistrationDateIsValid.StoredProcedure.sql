USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UAT_IsDeRegistrationDateIsValid]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UAT_IsDeRegistrationDateIsValid](@DATE DATETIME,@COMPANY_ID BIGINT)
AS BEGIN
 /* 
									    AUTHOR           : SREENIVASULU G
									    DATE OF CREATION : 21 - MARCH - 2016
										REQUIREMENT      : TO CHECK THE DOCDATE 
									 */ 
SELECT CompanyId,DocDate FROM [Bean].[Invoice] WHERE COMPANYID=@COMPANY_ID AND DOCDATE>=@DATE AND IsGstSettings=1
UNION
SELECT  CompanyId,DocDate FROM [Bean].[DebitNote]  WHERE COMPANYID=@COMPANY_ID AND DOCDATE>=@DATE  AND IsGstSettings=1
UNION
SELECT CompanyId,DocDate FROM [Bean].[Receipt] WHERE COMPANYID=@COMPANY_ID AND DOCDATE>=@DATE AND IsGstSettings=1
UNION
SELECT CompanyId,POSTINGDATE FROM [Bean].[Bill] WHERE COMPANYID=@COMPANY_ID AND POSTINGDATE>=@DATE  AND IsGstSettings=1
END
GO

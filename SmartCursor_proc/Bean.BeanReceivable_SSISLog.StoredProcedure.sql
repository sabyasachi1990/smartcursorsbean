USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Bean].[BeanReceivable_SSISLog]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Bean].[BeanReceivable_SSISLog] -- EXEC [Bean].[BeanReceivable_SSISLog]

AS
BEGIN

INSERT INTO Bean.BeanReceivablePackageLogs
SELECT
	'Bean Receivables Sp',GETDATE()
	
END
GO

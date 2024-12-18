USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKPROFILE_JOB]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [AppsWorldInt]
--GO
--/****** Object:  StoredProcedure [dbo].[SP_WORKPROFILE_JOB]    Script Date: 01/08/2017 1:15:35 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE PROCEDURE [dbo].[SP_WORKPROFILE_JOB](@WORKPROFILEID UNIQUEIDENTIFIER) 
AS
BEGIN
	DECLARE @CompanyId bigint;
	DECLARE @Count bigint;
	SET @Count= (SELECT Count(*) FROM Common.Company)
	DECLARE WorkProfileCursor CURSOR FOR SELECT Id FROM Common.Company
	OPEN WorkProfileCursor 

	WHILE @Count>0
	BEGIN
		FETCH WorkProfileCursor into @CompanyId
		Print @CompanyId

		BEGIN TRY
		if (@CompanyId <> 0)
			EXEC SP_WorkProfile @CompanyId,@WORKPROFILEID
		END TRY
		BEGIN CATCH
			Print 'Failed at Companyid: '
			Print @CompanyId 
		END CATCH

		SET @Count = @Count - 1
	END
	CLOSE WorkProfileCursor 
	deallocate WorkProfileCursor 	
END
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_CFDAYSUPDATE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HR_CFDAYSUPDATE] (@companyId BIGINT)
AS 
BEGIN
DECLARE @leaveTypeId UNIQUEIDENTIFIER,@cfDays float;
DECLARE SP_HR_CFDAYSUPDATE CURSOR FOR SELECT Id,NoOfDays from HR.LeaveType where CompanyId=@companyId
	OPEN SP_HR_CFDAYSUPDATE
		FETCH NEXT FROM SP_HR_CFDAYSUPDATE INTO @leaveTypeId,@cfDays
		WHILE(@@FETCH_STATUS=0)
		BEGIN

		update HR.LeaveEntitlement set CarryForwardDays=@cfDays where LeaveTypeId=@leaveTypeId
		 
		FETCH NEXT FROM SP_HR_CFDAYSUPDATE INTO @leaveTypeId,@cfDays
		END
	CLOSE SP_HR_CFDAYSUPDATE
DEALLOCATE SP_HR_CFDAYSUPDATE
END

GO

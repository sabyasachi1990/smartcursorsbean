USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_AuditTrials_FirstNameUpdate_claims]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [SP_HR_AuditTrials_FirstNameUpdate_claims] 19,'Claims'

CREATE PROCEDURE [dbo].[SP_HR_AuditTrials_FirstNameUpdate_claims] (@companyId BIGINT,@type Nvarchar(30))
AS 
BEGIN
DECLARE @id UNIQUEIDENTIFIER,@usercreated Nvarchar(100) ,@modifiedby Nvarchar(100);
DECLARE SP_HR_UserNameUpdate CURSOR FOR select Id,UserCreated,ModifiedBy from HR.HrAuditTrails where type=@type and typeid in (select id from hr.EmployeeClaim1 where ParentCompanyId=@companyId)
	OPEN SP_HR_UserNameUpdate
		FETCH NEXT FROM SP_HR_UserNameUpdate INTO @id,@usercreated,@modifiedby
		WHILE(@@FETCH_STATUS=0)
		BEGIN

		update HR.HrAuditTrails set 
		UserCreated=(select FirstName from Common.CompanyUser  where CompanyId=@companyId and Username=@usercreated) ,
		ModifiedBy =(select FirstName from Common.CompanyUser  where CompanyId=@companyId and Username=@modifiedby) 
		from HR.HrAuditTrails where  Id=@id
		 
		FETCH NEXT FROM SP_HR_UserNameUpdate INTO @id,@usercreated,@modifiedby
		END
	CLOSE SP_HR_UserNameUpdate
DEALLOCATE SP_HR_UserNameUpdate
END
GO

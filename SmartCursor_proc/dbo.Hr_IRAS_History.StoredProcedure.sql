USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Hr_IRAS_History]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Hr_IRAS_History] (@companyId bigint,@employeeIds nvarchar(max),@Content nvarchar(max),@year int,@generatedTime datetime)
	As Begin
		Begin Transaction
		BEGIN TRY	

		DECLARE @EmployeeIdTable TABLE (EmployeeId UNIQUEIDENTIFIER);
		INSERT INTO @EmployeeIdTable (EmployeeId)
			SELECT value FROM STRING_SPLIT(@employeeIds,',');
		DECLARE @Count int 
		Set @Count=(Select Count(*) From @EmployeeIdTable)
		if (@Count > 0)
			begin 
				update hr.IR8AHRSetUp set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.ir8a.errors'),GeneratedOn=@generatedTime where EmployeeId in (select EmployeeId from @EmployeeIdTable) and Year=@year
				update hr.IR8S set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.ir8s.errors'),GeneratedOn=@generatedTime where IR8AHRSetUpId in (select id from hr.IR8AHRSetUp (NOLOCK) where EmployeeId in (select EmployeeId from @EmployeeIdTable) and Year=@year)
				update hr.Appendix8A set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.a8a.errors'),GeneratedOn=@generatedTime where IR8AHRSetUpId in (select id from hr.IR8AHRSetUp (NOLOCK) where EmployeeId in (select EmployeeId from @EmployeeIdTable) and Year=@year)
				
			end
		else 
			begin
				update hr.IR8ACompanySetUp set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.ir8a.errors'),GeneratedOn=@generatedTime where CompanyId=@companyId and Year=@year
				update hr.IR8AHRSetUp set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.ir8a.errors'),GeneratedOn=@generatedTime where CompanyId=@companyId and Year=@year
				update hr.IR8S set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.ir8s.errors'),GeneratedOn=@generatedTime where IR8AHRSetUpId in (select id from hr.IR8AHRSetUp (NOLOCK) where year=@year and type='IR8A'and CompanyId=@companyId)
				update hr.Appendix8A set StatusCode=JSON_VALUE(@Content,'$.statusCode') ,StatusRemarks=JSON_query(@Content,'$.a8a.errors'),GeneratedOn=@generatedTime where IR8AHRSetUpId in (select id from hr.IR8AHRSetUp (NOLOCK) where year=@year and type='IR8A'and CompanyId=@companyId)
			end

    	Commit Transaction
		END TRY
		BEGIN CATCH
			RollBack Transaction;
			DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH
	END
GO

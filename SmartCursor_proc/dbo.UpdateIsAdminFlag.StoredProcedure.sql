USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UpdateIsAdminFlag]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[UpdateIsAdminFlag]
   @CompanyId bigint  
AS
BEGIN
Begin Transaction
Begin Try

if exists(select * from common.TimeLogDetail  where MasterId in (select Id from common.TimeLog where CompanyId=@CompanyId and TimeLogItemId in ( select Id from Common.TimeLogItem where (IsSystem=0 or IsSystem is null) and CompanyId=@CompanyId ) ))

begin

--print @CompanyId
   update common.TimeLogDetail set IsAdmin=1 where MasterId in (select Id from common.TimeLog where CompanyId=@CompanyId and TimeLogItemId in ( select Id from Common.TimeLogItem where (IsSystem=0 or IsSystem is null) and CompanyId=@CompanyId) )
   end

   Commit Transaction--s2
	End try --s3
	Begin Catch
	ROLLBACK TRANSACTION
		DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
		SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	End Catch
	end--1
GO

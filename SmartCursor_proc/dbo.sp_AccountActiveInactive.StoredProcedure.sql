USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_AccountActiveInactive]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---->>> EXEC [dbo].[sp_AccountActiveInactive]  
  
CREATE PROCEDURE [dbo].[sp_AccountActiveInactive]  
  
AS 
BEGIN

DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

BEGIN TRANSACTION
BEGIN TRY

SELECT * INTO #Temp 
FROM
	(
		SELECT DISTINCT A.Id, COUNT(A.Id) AS IdCount
		FROM ClientCursor.Account AS A (NOLOCK)
		INNER JOIN ClientCursor.Opportunity opp(NOLOCK) ON OPP.AccountId = A.Id 
		WHERE A.IsAccount=1 AND A.BatchListingDate is null AND (opp.Stage  IN ('Created','Won','Quoted','Pending') OR (IsTemp = 1 AND Nature='Recurring'))
		GROUP BY A.Id
	) AS A

--SELECT DISTINCT A.Id,B.Id
--FROM ClientCursor.Account AS A
--LEFT JOIN #Temp AS B ON B.Id = A.Id 
--WHERE A.IsAccount=1 AND A.BatchListingDate IS NULL AND B.Id IS NULL

UPDATE A SET
	A.BatchListingDate = GETDATE(),
	A.BatchListingStatus = 'InActive',
	A.ShowBatchListing = 1
FROM ClientCursor.Account AS A
LEFT JOIN #Temp AS B ON B.Id = A.Id 
INNER JOIN ClientCursor.Opportunity opp(NOLOCK) ON OPP.AccountId = A.Id 
WHERE A.IsAccount=1 AND A.BatchListingDate IS NULL AND B.Id IS NULL AND OPP.Stage = 'Complete' AND ((ISNULL(IsTemp,0) != 1 AND Nature = 'Recurring') OR Nature != 'Recurring')

COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH

DROP TABLE #Temp

END

--Declare @Id uniqueIdentifier  
  
--Declare user_cursor cursor for select Id from ClientCursor.Account where IsAccount=1 and BatchListingDate is null
  
--open user_cursor  
--fetch next from user_cursor into @Id 
--While @@FETCH_STATUS=0  
  
--Begin  
   
--   Declare @NonCompletecount int 
--   Declare @Completecount int 
--   set @NonCompletecount = (select count(*) from  ClientCursor.Opportunity opp where  (opp.Stage  in ('Created','Won','Quoted','Pending') or (IsTemp=1 and Nature='Recurring')) and opp.AccountId=@Id) 

--   if(@NonCompletecount=0 or @NonCompletecount is null)
--   begin
--   set @Completecount = (select count(*) from ClientCursor.Opportunity opp where  opp.Stage  in ('Complete') and opp.AccountId=@Id)
--   if(@Completecount>0)
--   begin
--   update ClientCursor.Account set BatchListingDate=GETDATE(),BatchListingStatus='Inactive',ShowBatchListing=1 where Id=@Id
--   end
--   end



--Fetch Next From user_cursor into @Id
--end  
--close user_cursor  
--deallocate user_cursor  
--end  
  
  
GO

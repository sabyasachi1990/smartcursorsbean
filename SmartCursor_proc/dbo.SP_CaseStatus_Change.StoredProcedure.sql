USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CaseStatus_Change]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CaseStatus_Change](@Ids NVARCHAR(Max))
AS 
 BEGIN
 IF @Ids IS NOT NULL 
 BEGIN   
	  DECLARE @t TABLE(id NVARCHAR(Max)) 
	  INSERT @t VALUES (@Ids)  
	  Declare @id NVARCHAR(Max)
	  DECLARE Case_Cursor CURSOR FOR 
		  SELECT  LTRIM(RTRIM(m.n.value('.[1]','NVARCHAR(Max)'))) AS id FROM (SELECT CAST('<XMLRoot><RowData>' + 
		  REPLACE(id,',','</RowData><RowData>')  + '</RowData></XMLRoot>' AS XML) AS x 
		  FROM   @t)t CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
		  OPEN Case_Cursor;  
		  FETCH NEXT FROM Case_Cursor into @id
		  WHILE @@FETCH_STATUS = 0  
			 BEGIN  
				DECLARE @COUNT INT
				declare @Stage nvarchar(50)
				   SET @Stage =(Select Stage from WorkFlow.CaseGroup  where id in (Select SystemId from Common.TimeLogItem   where id=@id))
				SET @COUNT=(SELECT COUNT(*) AS COUNT FROM WORKFLOW.CASEGROUP WHERE ID IN (SELECT dISTINCT ti.SystemId FROM Common.TimeLog T 
				JOIN Common.TimeLogItem TI ON TI.Id=T.TimeLogItemId WHERE TI.Id = @id  and @id=(select Top 1 TimeLogItemId from common.TimeLog where timelogitemid = @id)) AND STAGE ='In-Progress')
				IF @COUNT=0
				begin
				SET @COUNT=(select count( TimeLogItemId) from common.TimeLog where timelogitemid = @id);
				end
				IF @COUNT=0
				BEGIN
					DECLARE @TIME DECIMAL 
					SET @TIME=(SELECT CASE WHEN SUM(DATEDIFF(MINUTE,0,TD.Duration))/60.0 is null THEN 0
            ELSE SUM(DATEDIFF(MINUTE,0,TD.Duration))/60.0 END AS HOURS  FROM Common.TimeLog T JOIN Common.TimeLogItem TI 
					ON TI.Id=T.TimeLogItemId LEFT JOIN Common.TimeLogDetail TD ON  TD.MasterId=T.Id WHERE TI.Id=@id)
						IF @TIME <= 0 and (  @Stage!='Complete'  and @Stage!='Cancelled' and  @Stage!='On hold'and @Stage!='Unassigned' and @Stage!='Approve'and @Stage!='For Approval' )
						BEGIN 
						UPDATE WorkFlow.CaseGroup SET Stage='Assigned',ApprovedDate=null WHERE ID=(SELECT Id AS COUNT FROM WORKFLOW.CASEGROUP
						 WHERE ID IN (SELECT dISTINCT SystemId FROM Common.TimeLogItem where Id = @id))
						END
				END
			 FETCH NEXT FROM Case_Cursor into @id
			 END;  
		  CLOSE Case_Cursor;  
	  DEALLOCATE Case_Cursor;   
 END
 
END
GO

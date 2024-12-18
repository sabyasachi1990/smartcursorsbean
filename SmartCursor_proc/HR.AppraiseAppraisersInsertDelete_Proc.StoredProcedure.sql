USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[AppraiseAppraisersInsertDelete_Proc]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [HR].[AppraiseAppraisersInsertDelete_Proc]  ----->>> EXEC HR.AppraiseAppraisersInsertDelete_Proc @AppraisalId,@TempApprisers                
    @AppraisalId UNIQUEIDENTIFIER,                
    @TempApprisers TempAppraisers READONLY                
                
                
                
                
AS                
BEGIN                
                
          
                
DECLARE @ErrMessage Nvarchar(max)                
                
                
                
SELECT * INTO #Temp FROM                
(                
    SELECT CAST([value] AS uniqueidentifier) as AppraiserId, AppraiseeId, IsSelfAppraiser,AppraiserRecordStatus              
    FROM @TempApprisers                   
        CROSS APPLY STRING_SPLIT(AppraiserIds, ',')                
) AS A                
                
                
                
BEGIN TRAN                
BEGIN TRY                
                
                
                
IF EXISTS (Select count(AppraiseeId) from #Temp where AppraiserRecordStatus='Added')                
BEGIN                
                
                
          
            
       INSERT INTO [HR].[AppraiseAppraisers] ([Id ],AppraisalDetailId,AppraiserId,IsSelfAppraiser,IsSelected)                
        SELECT NEWID(),a.Id,b.AppraiserId,case when AppraiserId=AppraiseeId then 1 else 0 end,1              
        FROM [Hr].[AppraisalAppraiseeDetails] AS A                
        INNER JOIN #Temp AS B                
        ON A.EmployeeId = B.AppraiseeId                
        WHERE A.AppraisalId  = @AppraisalId and b.AppraiserRecordStatus='Added'  And      
  B.AppraiserId Not in (Select AppraiserId From [HR].[AppraiseAppraisers] where AppraisalDetailId in (a.Id))      
        
        
       
            
                
                
END                    
                
                
                
IF EXISTS                
    (Select count(AppraiseeId) from #Temp where AppraiserRecordStatus='Deleted')                
BEGIN                
                
                
                
Delete B FROM [HR].[AppraiseAppraisers] as B (NOLOCK)                
WHERE B.[AppraisalDetailId] IN (                
                                SELECT DISTINCT a.Id FROM [Hr].[AppraisalAppraiseeDetails] AS A                
                                INNER JOIN #Temp AS B                
                                ON A.EmployeeId = B.AppraiseeId                
                                WHERE AppraiserRecordStatus = 'Deleted'  AND A.AppraisalId  = @AppraisalId                                                
                                )                
                                AND B.AppraiserId IN (SELECT AppraiserId FROM #Temp WHERE AppraiserRecordStatus = 'Deleted')      


     Delete B FROM [HR].[AppraiserIncharge] as B (NOLOCK)                
WHERE B.[AppraisalDetailId] IN (                
                                SELECT DISTINCT a.Id FROM [Hr].[AppraisalAppraiseeDetails] AS A                
                                INNER JOIN #Temp AS B                
                                ON A.EmployeeId = B.AppraiseeId                
                                WHERE AppraiserRecordStatus = 'Deleted'  AND A.AppraisalId  = @AppraisalId                                                
                                )                
                                AND B.InchargeId IN (SELECT AppraiserId FROM #Temp WHERE AppraiserRecordStatus = 'Deleted')           
END                
            
     
      Update [HR].[AppraisalAppraiseeDetails] set AppraiserCount =  
        ((Select Count([Id ])from  Hr.AppraiseAppraisers where AppraisalDetailId in   
        (Select Id from HR.AppraisalAppraiseeDetails where EmployeeId in (Select Top 1 AppraiseeId FROM #Temp) and AppraisalId =@AppraisalId)) )   
        where AppraisalId=@AppraisalId and   
               EmployeeId in (Select Top 1 AppraiseeId FROM #Temp)  
  
  Update HR.Appraisal set AppraisersCount =            
  (Select Count(Distinct(AppraiserId)) From Hr.AppraiseAppraisers (NoLock) where AppraisalDetailId in             
  (Select Id from hr.AppraisalAppraiseeDetails (NoLock) where             
   AppraisalId =@AppraisalId))            
  where Id=@AppraisalId            
                
  Select AppraisersCount as AppraisersCount,AppraiseesCount as AppraiseesCount from Hr.Appraisal where Id=@AppraisalId        
              
COMMIT TRAN                
END TRY                
                
                
                
BEGIN CATCH                
    ROLLBACK                
    SET @ErrMessage = ERROR_MESSAGE()                
    RAISERROR(@ErrMessage, 16,1);                    
                
                
                
END CATCH                
                
                
                
                
DROP TABLE #Temp                
                
                
                
                
                
                
END
GO

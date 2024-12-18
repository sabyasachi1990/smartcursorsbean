USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[AppraiseAppraisersInchargeInsertDelete_Proc]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--CREATE TYPE [dbo].[TempIncharges1] AS TABLE(
--    [InchargeId] [nvarchar](max) NOT NULL,
--    [AppraiseeId] [uniqueidentifier] NOT NULL,
--    [InchargeRecordStatus] [nvarchar](25) NOT NULL)

	--Declare @tempa as [TempIncharges]  
--alter  table @tempa  drop column IsSelected
--select * from @tempa



create PROCEDURE [HR].[AppraiseAppraisersInchargeInsertDelete_Proc]                 
    @AppraisalId UNIQUEIDENTIFIER,                
    @TempIncharges TempIncharges1 READONLY                
               
                
AS                
BEGIN                
                
          
                
DECLARE @ErrMessage Nvarchar(max)                
                
                
                
SELECT * INTO #Temp FROM                
(                
    SELECT CAST([value] AS uniqueidentifier) as InchargeId, AppraiseeId,InchargeRecordStatus              
    FROM @TempIncharges                   
        CROSS APPLY STRING_SPLIT(InchargeId, ',')                
) AS A                
                
                
                
BEGIN TRAN                
BEGIN TRY 

      
      IF EXISTS (Select count(AppraiseeId) from #Temp where InchargeRecordStatus='Added')                
BEGIN       
       INSERT INTO [HR].[AppraiserIncharge] ([Id],AppraisalDetailId,InchargeId,IsSelected)                
        SELECT NEWID(),a.Id,b.InchargeId ,1              
        FROM [Hr].[AppraisalAppraiseeDetails] AS A                
        INNER JOIN #Temp AS B                
        ON A.EmployeeId = B.AppraiseeId                
        WHERE A.AppraisalId  = @AppraisalId and b.InchargeRecordStatus='Added'  And      
  B.InchargeId Not in (Select InchargeId From [HR].[AppraiserIncharge] where AppraisalDetailId in (a.Id))      
        
        
       
            
                
                
END                    
                
                
                
IF EXISTS                
    (Select count(AppraiseeId) from #Temp where InchargeRecordStatus='Deleted')                
BEGIN                
                
                
                
Delete B FROM [HR].[AppraiserIncharge] as B (NOLOCK)                
WHERE B.[AppraisalDetailId] IN (                
                                SELECT DISTINCT a.Id FROM [Hr].[AppraisalAppraiseeDetails] AS A                
                                INNER JOIN #Temp AS B                
                                ON A.EmployeeId = B.AppraiseeId                
                                WHERE InchargeRecordStatus = 'Deleted'  AND A.AppraisalId  = @AppraisalId                                                
                                )                
                                AND B.InchargeId IN (SELECT InchargeId FROM #Temp WHERE InchargeRecordStatus = 'Deleted')                
END                
    
	Select Count(*) as InchargeCount From [HR].[AppraiserIncharge] as AI join [Hr].[AppraisalAppraiseeDetails] as AAD  on AI.AppraisalDetailId= AAD.Id where  AppraisalDetailId in (AAD.Id)and AAD.AppraisalId=@AppraisalId
         
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

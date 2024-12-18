USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[AppraisersAppraiseInsertDelete_Proc]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROCEDURE [HR].[AppraisersAppraiseInsertDelete_Proc]  ----->>> EXEC HR.AppraiseAppraisersInsertDelete_Proc @AppraisalId,@TempApprisers                  
    @AppraisalId UNIQUEIDENTIFIER,                  
    @TempApprisees TempAppraisers READONLY  
     
                  
                  
AS                  
BEGIN    
                              
DECLARE @ErrMessage Nvarchar(max)                               
             
SELECT * INTO #TempAppraisees FROM                  
(                  
    SELECT CAST([value] AS uniqueidentifier) as AppraiseeId,AppraiseeId as AppraiserId,AppraiserRecordStatus as RecordStatus,IsSelfAppraiser as IsSelfAppraisee                
    FROM @TempApprisees                     
        CROSS APPLY STRING_SPLIT(AppraiserIds, ',')                  
) AS A                  
                  
                  
BEGIN TRAN                  
BEGIN TRY                            
                    
             Declare @appraiserId uniqueidentifier,@appraiseeId uniqueidentifier,@recordStatus Nvarchar(250),@isSelefAppraisee Bit  
     Declare appraisers Cursor for (Select AppraiserId,AppraiseeId,RecordStatus,IsSelfAppraisee from #TempAppraisees )  
     Open appraisers  
      FETCH NEXT FROM appraisers into @appraiserId,@appraiseeId,@recordStatus,@isSelefAppraisee 
               WHILE @@FETCH_STATUS = 0  
               BEGIN  
        If (@recordStatus='Added')  
       Begin  
                  INSERT INTO [HR].[AppraiseAppraisers] ([Id ],AppraisalDetailId,AppraiserId,IsSelfAppraiser,IsSelected)                  
                  SELECT NEWID(),(Select Id from [HR].[AppraisalAppraiseeDetails] where EmployeeId=@appraiseeId and AppraisalId=@AppraisalId),@appraiserId,@isSelefAppraisee ,1
  
     
                     Update [HR].[AppraisalAppraiseeDetails] set IsSelected=1,AppraiserCount =  
        ((Select Count([Id ])from  Hr.AppraiseAppraisers where AppraisalDetailId in   
        (Select Id from HR.AppraisalAppraiseeDetails where EmployeeId=@appraiseeId and AppraisalId =@AppraisalId)) )   
        where AppraisalId=@AppraisalId and   
               EmployeeId in (@appraiseeId)  
    End  
    
             If(@recordStatus='Deleted')      
               Begin  
                 Delete B FROM [HR].[AppraiseAppraisers] as B (NOLOCK) WHERE B.[AppraisalDetailId] IN (                  
                                            SELECT DISTINCT a.Id FROM [Hr].[AppraisalAppraiseeDetails] AS A                  
                                            where a.EmployeeId=@appraiseeId and AppraisalId=@AppraisalId)  
           and AppraiserId in (@appraiserId)  
                   
     If((Select Count([Id ])   from  Hr.AppraiseAppraisers where AppraisalDetailId in (Select Id from HR.AppraisalAppraiseeDetails where EmployeeId=@appraiseeId and AppraisalId =@AppraisalId))=0)  
                    Begin  
           Update [HR].[AppraisalAppraiseeDetails] set IsSelected=0,AppraiserCount =  
        ((Select Count([Id ])from  Hr.AppraiseAppraisers where AppraisalDetailId in   
        (Select Id from HR.AppraisalAppraiseeDetails where EmployeeId=@appraiseeId and AppraisalId =@AppraisalId)) )   
        where AppraisalId=@AppraisalId and   
                   EmployeeId in (@appraiseeId)  
    End  
                 
             End    
                             
  FETCH NEXT FROM appraisers into @appraiserId,@appraiseeId,@recordStatus,@isSelefAppraisee      
  End  
  Close appraisers  
  Deallocate appraisers  
    
          
      If Exists(Select Id From Hr.Appraisal where Id=@AppraisalId and AppraiserList='Selected')  
    Begin  
          Update HR.Appraisal set AppraisersCount =              
          (Select Count(Distinct(AppraiserId)) From Hr.AppraiseAppraisers (NoLock) where AppraisalDetailId in               
          (Select Id from hr.AppraisalAppraiseeDetails (NoLock) where               
           AppraisalId =@AppraisalId and IsSelected=1)),AppraiseesCount=(Select COUNT(Id) from [Hr].[AppraisalAppraiseeDetails] where AppraisalId=@AppraisalId and IsSelected=1 )              
          where Id=@AppraisalId     
   End  
          
            
                      
                  
  Select AppraisersCount as AppraisersCount,AppraiseesCount as AppraiseesCount from Hr.Appraisal where Id=@AppraisalId          
                
COMMIT TRAN                  
END TRY                  
                  
                  
                  
BEGIN CATCH                  
    ROLLBACK                  
    SET @ErrMessage = ERROR_MESSAGE()                  
    RAISERROR(@ErrMessage, 16,1);                      
                  
                  
                  
END CATCH                  
                  
                  
                  
                  
DROP TABLE #TempAppraisees                  
                  
                  
                  
                  
                  
                  
END
GO

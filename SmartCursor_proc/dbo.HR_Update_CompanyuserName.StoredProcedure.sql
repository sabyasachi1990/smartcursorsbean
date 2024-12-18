USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Update_CompanyuserName]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 Create procedure [dbo].[HR_Update_CompanyuserName] (@UserId bigint)--- Exec [HR_Update_CompanyuserName] 75
 
 as 
 Begin 
   --Declare @UserId bigint=75
   Declare @RecommenderIds table (Id uniqueidentifier)
   Declare @ApproverIds table (Id uniqueidentifier)

   --====================== GET RecommenderIds  using Userid================================================
    insert into @RecommenderIds
     select A.ID 
     FROM Common.companyuser B
     INNER JOIN 
     (
      Select A.Id,value RecommenderIds
      from [HR].[LeaveApplication] A 
      CROSS APPLY STRING_SPLIT(A.[LeaveRecommenderIds], ',')
      WHERE A.[LeaveRecommenderIds] IS not NULL and  A.[LeaveRecommenderIds] <> 'N/A' AND A.[LeaveRecommenderIds]<>''
      )A ON A.RecommenderIds=B.ID
	  where B.Id=@UserId
      GROUP BY A.ID 
	    --====================== GET ApproverIds  using Userid================================================
	  insert into @ApproverIds
	  select A.ID 
      FROM Common.companyuser B
      INNER JOIN 
     (
      Select A.Id,value ApproverIds
      from [HR].[LeaveApplication] A 
      CROSS APPLY STRING_SPLIT(A.LeaveApproverIds, ',')
      WHERE A.[LeaveApproverIds] IS not NULL and  A.[LeaveApproverIds] <> 'N/A' AND A.[LeaveApproverIds]<>''
      )A ON A.ApproverIds=B.ID
	   where B.Id=@UserId
       GROUP BY A.ID 

      
	 -- --=======================UPDATE RecommenderName============================
     Update A SET A.RecommenderName=c.FirstName
     --Select A.RecommenderUserId,A.RecommenderName,c.Id,c.FirstName
     from [HR].[LeaveApplication] A 
     INNER JOIN Common.companyuser C ON C.ID=A.RecommenderUserId
	 where c.id=@UserId
     
  --   --==============================UPDATE ApproverName===========================
     Update A SET A.ApproverName=c.FirstName
     --Select A.ApproverUserId,A.ApproverName,c.Id,c.FirstName
     from [HR].[LeaveApplication] A 
     INNER JOIN Common.companyuser C ON C.ID=A.ApproverUserId
	 where c.id=@UserId

      --======================UPDATE LeaveRecommenders============================
      Update AA SET AA.LeaveRecommenders=BB.List_Output 
     --SELECT AA.Id,AA.LeaveRecommenders,BB.List_Output,LeaveRecommenderIds 
     FROM [HR].[LeaveApplication] AA 
     INNER JOIN 
       (
     select A.ID ,STRING_AGG(B.FirstName  , ', ') AS List_Output 
     FROM Common.companyuser B
     INNER JOIN 
     (
      Select A.Id,value RecommenderIds
      from [HR].[LeaveApplication] A 
      CROSS APPLY STRING_SPLIT(A.[LeaveRecommenderIds], ',')
      WHERE A.[LeaveRecommenderIds] IS not NULL and  A.[LeaveRecommenderIds] <> 'N/A' AND A.[LeaveRecommenderIds]<>''---7768
	   AND A.Id in (select * from @RecommenderIds)
      )A ON A.RecommenderIds=B.ID
      GROUP BY A.ID 
     )BB ON AA.ID=BB.ID

     ----==============================UPDATE LeaveApprovers===================================
     
      Update AA SET AA.LeaveApprovers=BB.List_Output 
     --SELECT AA.Id,AA.LeaveApprovers,BB.List_Output,AA.LeaveApproverIds 
     FROM [HR].[LeaveApplication] AA 
     INNER JOIN 
       (
     select A.ID ,STRING_AGG(B.FirstName  , ', ') AS List_Output 
     FROM Common.companyuser B
     INNER JOIN 
     (
      Select A.Id,value ApproverIds
      from [HR].[LeaveApplication] A 
      CROSS APPLY STRING_SPLIT(A.LeaveApproverIds, ',')
      WHERE A.[LeaveApproverIds] IS not NULL and  A.[LeaveApproverIds] <> 'N/A' AND A.[LeaveApproverIds]<>''
      AND A.Id in (select * from @ApproverIds)
      )A ON A.ApproverIds=B.ID
      GROUP BY A.ID 
     )BB ON AA.ID=BB.ID

 END
GO

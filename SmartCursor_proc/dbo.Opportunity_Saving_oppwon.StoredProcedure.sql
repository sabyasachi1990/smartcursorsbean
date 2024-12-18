USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Opportunity_Saving_oppwon]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   

	
	
--========================================================= 1st
	 
	 -- select * from ClientCursor.Opportunity where companyid=459 and Stage='Won' and id in 
	 --(select o.id  as oppid
		--   from WorkFlow.CaseGroup c
		--   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		--   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		--   inner join ClientCursor.OpportunityStatusChange os on os.OpportunityId=o.Id
		--   where c.CompanyId =459 and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		--  and o.Stage='Won' and os.State='Won')




		--    select * from ClientCursor.OpportunityStatusChange where companyid=459 and State='Won' and OpportunityId in 
	 --(select o.id  as oppid
		--   from WorkFlow.CaseGroup c
		--   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		--   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		--   inner join ClientCursor.OpportunityStatusChange os on os.OpportunityId=o.Id
		--   where c.CompanyId =459 and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		--  and o.Stage='Won' and os.State='Won')

--====================================================1st


     --========================== 2rd


	 --		    delete from ClientCursor.OpportunityStatusChange where companyid=459 and State='complete' and OpportunityId in 
	 --(select o.id  as oppid
		--   from WorkFlow.CaseGroup c
		--   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		--   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		--   inner join ClientCursor.OpportunityStatusChange os on os.OpportunityId=o.Id
		--   where c.CompanyId =? and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		--  and o.Stage='complete' and os.State='complete')



	--update o set o.Stage='Won',o.ModifiedBy='Chin Ee Lin',o.ModifiedDate=DATEADD(MINUTE,-1,o.ModifiedDate)
	--	   from WorkFlow.CaseGroup c
	--	   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
	--	   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
	--	   inner join ClientCursor.OpportunityStatusChange os on os.OpportunityId=o.Id
	--	   where c.CompanyId =? and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
	--	and o.Stage='complete' and os.State='complete'



		--========================== 2rd	
	
CREATE procedure  [dbo].[Opportunity_Saving_oppwon]
as
begin

Declare @CompanyId int
Declare @oppid uniqueidentifier
Declare @oppNumber Nvarchar(Max)
Declare @Stage Nvarchar(Max)
Declare @CreatedDate datetime2
Declare @ModifiedDate datetime2

	
	Declare oppId_Csr Cursor For
     	
	 select o.id  as oppid,o.OpportunityNumber,o.Stage,o.CreatedDate,os.ModifiedDate,o.CompanyId
		   from WorkFlow.CaseGroup c
		   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		   inner join ClientCursor.OpportunityStatusChange os on os.OpportunityId=o.Id
		   where c.CompanyId =@CompanyId and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		  and o.Stage='Won' and os.State='Won'

	Open oppId_Csr;
	Fetch Next From oppid_Csr Into  @oppid,@oppNumber,@Stage,@CreatedDate,@ModifiedDate,@CompanyId
	While @@FETCH_STATUS=0
	Begin

	  if Not Exists ( select Id from ClientCursor.OpportunityStatusChange where CompanyId=@CompanyId and OpportunityId=@oppid and State='Complete')
	  begin 

	 Insert into ClientCursor.OpportunityStatusChange (Id,CompanyId,OpportunityId,State,ModifiedBy,ModifiedDate )
     select Newid(),@CompanyId,@oppid,'Complete','System',DATEADD(MINUTE,1,@ModifiedDate) from  
	 ClientCursor.OpportunityStatusChange where CompanyId=@CompanyId and OpportunityId=@oppid and State='Won'

      update ClientCursor.Opportunity set Stage='Complete',ModifiedBy='System',
	  ModifiedDate=DATEADD(MINUTE,1,@ModifiedDate)
	  where CompanyId=@CompanyId and id=@oppid and Stage='Won'
	  end 
	Fetch Next From oppId_Csr Into @oppid,@oppNumber,@Stage,@CreatedDate,@ModifiedDate,@CompanyId
	End
	Close oppId_Csr
	Deallocate oppId_Csr

	end


	


	--------------------======================== 2nd 

  --SELECT * FROM WorkFlow.CaseStatusChange WHERE CompanyId=459 AND ID NOT IN ( SELECT Id FROM CASEUnassigned)

	    --  SELECT C.Stage,N.STAGE,C.ModifiedBy,N.ModifiedBy,
	    -- C.ModifiedDate,C.ApprovedDate,N.ApprovedDate
	    --,C.AssignedDate,N.AssignedDate,C.ActualDateOfCompletion,N.ActualDateOfCompletion FROM WorkFlow.CaseGroup C
	    -- INNER JOIN CASEUnassignedNEW N ON N.Caseid=C.ID
	    -- where C.CompanyId=459 

--------------------======================== 2nd 

     --========================== 3rd

		 	--DELETE FROM WorkFlow.CaseStatusChange WHERE CompanyId=459 AND ID NOT IN ( SELECT Id FROM CASEUnassigned)
	
	    --     UPDATE C SET
	    --  C.Stage=N.STAGE,C.ModifiedBy=N.ModifiedBy,
	    -- C.ModifiedDate=NULL,C.ApprovedDate=N.ApprovedDate
	    --,C.AssignedDate=N.AssignedDate,C.ActualDateOfCompletion=N.ActualDateOfCompletion FROM WorkFlow.CaseGroup C
	    -- INNER JOIN CASEUnassignedNEW N ON N.Caseid=C.ID
	    -- where C.CompanyId=459 

		--========================== 3rd





	
GO

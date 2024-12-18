USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Casestatus_Saving_oppwon]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
	
	  
--========================================================= 1st
   --       select * into CASEUnassignedNEW from 
		 --(
   --       select C.ID AS caseid,c.Stage ,c.ModifiedBy,c.ModifiedDate,c.ApprovedDate,c.AssignedDate,c.ActualDateOfCompletion  from WorkFlow.CaseGroup c
		 --  inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		 --   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		 --   where c.CompanyId =459 and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
			--)kk

			--  select * into CASEUnassigned from 
			--(
			--SELECT * FROM WorkFlow.CaseStatusChange WHERE CompanyId=459
			--)gg

--====================================================1st

--------------------======================== 2nd 

  --SELECT * FROM WorkFlow.CaseStatusChange WHERE CompanyId=459 AND ID NOT IN ( SELECT Id FROM CASEUnassigned) --250

	    --  SELECT c.Id,c.CaseNumber,C.Stage,N.stage,C.ModifiedBy,N.ModifiedBy,  --120
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
	
CREATE procedure  [dbo].[Casestatus_Saving_oppwon]
as
begin

Declare @CompanyId int--=?
Declare @Caseid uniqueidentifier
Declare @CaseNumber Nvarchar(Max)
Declare @Stage Nvarchar(Max)
Declare @CreatedDate datetime2
Declare @ModifiedDate datetime2

	
	Declare CaseId_Csr Cursor For
     	
	 select c.id  as Caseid,c.CaseNumber,c.Stage,c.CreatedDate,s.ModifiedDate,c.CompanyId
		   from WorkFlow.CaseGroup c
		   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		   inner join WorkFlow.CaseStatusChange s on s.CaseId=c.Id
		   where c.CompanyId =@CompanyId and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		
	Open CaseId_Csr;
	Fetch Next From Caseid_Csr Into  @Caseid,@CaseNumber,@Stage,@CreatedDate,@ModifiedDate,@CompanyId
	While @@FETCH_STATUS=0
	Begin

	  if Not Exists ( select Id from WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Complete')
	  begin 

	 Insert into WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
     select Newid(),@CompanyId,@Caseid,'Assigned','System',DATEADD(MINUTE,1,@ModifiedDate) from  WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Unassigned'

	  Insert into WorkFlow.CaseStatusChange(Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
	  select Newid(),@CompanyId,@Caseid,'In-Progress','System',DATEADD(MINUTE,2,@ModifiedDate)from  WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Unassigned'

	  Insert into WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
      select Newid(),@CompanyId,@Caseid,'Approve','System',DATEADD(MINUTE,3,@ModifiedDate)from  WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Unassigned'

	  Insert into WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
	  select Newid(),@CompanyId,@Caseid,'Complete','System',DATEADD(MINUTE,4,@ModifiedDate)from  WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Unassigned'

      update WorkFlow.CaseGroup set Stage='Complete',ModifiedBy='System',
	  ModifiedDate=DATEADD(MINUTE,4,@ModifiedDate),ApprovedDate=DATEADD(MINUTE,3,@ModifiedDate)
	  ,AssignedDate=DATEADD(MINUTE,1,@ModifiedDate),ActualDateOfCompletion=DATEADD(MINUTE,4,@ModifiedDate)
	   where CompanyId=@CompanyId and id=@Caseid and Stage='Unassigned'
	  end 
	Fetch Next From CaseId_Csr Into @Caseid,@CaseNumber,@Stage,@CreatedDate,@ModifiedDate,@CompanyId
	End
	Close CaseId_Csr
	Deallocate CaseId_Csr

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

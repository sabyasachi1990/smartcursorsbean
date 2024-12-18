USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Schedule_saving_oppwon]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [SmartCursorPRDLive]
--GO
--/****** Object:  StoredProcedure [dbo].[Schedule_saving_oppwon]    Script Date: 11/04/2019 9:00:36 AM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO


 CREATE procedure [dbo].[Schedule_saving_oppwon]
 as
 begin
Declare @CompanyId int----=459
Declare @caseid uniqueidentifier
Declare @caseNumber Nvarchar(Max)
Declare @Stage Nvarchar(Max)
Declare @CreatedDate datetime2
Declare @ModifiedDate datetime2

	
	Declare ScheduleId_Csr Cursor For
     	
	 select c.id  as caseid,c.CaseNumber,c.Stage,c.CreatedDate,c.CompanyId
		   from WorkFlow.CaseGroup c
		   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
		   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
		   where c.CompanyId =@CompanyId and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
		  and o.Stage='complete' and c.Stage='complete'

	Open ScheduleId_Csr;
	Fetch Next From Scheduleid_Csr Into  @caseid,@caseNumber,@Stage,@CreatedDate,@CompanyId
	While @@FETCH_STATUS=0
	Begin

	  if Not Exists ( select Id from WorkFlow.Schedule where CompanyId=@CompanyId and CaseId=@caseid and Status=1)
	  begin 


	  	insert into WorkFlow.Schedule ( id,CompanyId,CaseId,StartDate,CompletionDate,UserCreated,CreatedDate,Status )
        values(newid(),@CompanyId,@caseid,'2019-08-01 00:00:00.0000000','2019-08-31 00:00:00.0000000','system',GETutcDATE(),1)

		 --  select  id,CompanyId,CaseId,StartDate,CompletionDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,
		 --Status from WorkFlow.Schedule where CompanyId=459

	  end 
	Fetch Next From ScheduleId_Csr Into @caseid,@caseNumber,@Stage,@CreatedDate,@CompanyId
	End
	Close ScheduleId_Csr
	Deallocate ScheduleId_Csr
	end



	--   select  id,CompanyId,CaseId,StartDate,CompletionDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,
	--	 Status from WorkFlow.Schedule where CompanyId=459 and caseid in 
	--(
	--	 select c.id  as caseid
	--	   from WorkFlow.CaseGroup c
	--	   inner join  ClientCursor.Opportunity o on o.CaseId=c.Id
	--	   inner join [CA.SGOpp] Ca on ca.[Opp Ref# No]=o.OpportunityNumber
	--	   where c.CompanyId =459 and OpportunityNumber  not in ('OPP-09/2019-00060','OPP-08/2019-00002','OPP-08/2019-00001','OPP-09/2019-00102','OPP-09/2019-00101')
	--	  and o.Stage='complete' and c.Stage='complete'
	--	  )


	--select Id from WorkFlow.Schedule where CompanyId=459  and Status=1



GO

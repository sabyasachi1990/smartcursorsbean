USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_updateIsTimeLogFlag]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Migration_updateIsTimeLogFlag]   -- exec  [dbo].[Migration_updateIsTimeLogFlag] '99B96CA5-3F42-4176-BE4C-BEFAB9ED3CEB','CC51AC0E-6226-4965-A22F-40FFC6F43D43'
 as
 begin 
  --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================


    Declare  @Caseid uniqueidentifier,
    @EmployeeId uniqueidentifier,
	@ScheduleId  uniqueidentifier,
	@ScheduleDetailId uniqueidentifier

	Declare MigrationIsTimeLogFlag_Csr Cursor For  
    select distinct  s.CaseId,sd.EmployeeId  from WorkFlow.ScheduleNew s
	inner join WorkFlow.ScheduleDetailNew sd on sd.MasterId=s.Id order by s.CaseId,sd.EmployeeId
    Open MigrationIsTimeLogFlag_Csr		  
    Fetch Next From MigrationIsTimeLogFlag_Csr  into @Caseid,@EmployeeId
	While @@FETCH_STATUS=0
    BEGIN
       Declare updateIsTimeLogFlag_Csr Cursor For  
       select distinct s.CaseId,s.id as ScheduleId, sd.id as ScheduleDetailId,sd.EmployeeId  from WorkFlow.ScheduleNew s
	   inner join WorkFlow.ScheduleDetailNew sd on sd.MasterId=s.Id where 
	   s.CaseId =@Caseid and 
	   sd.EmployeeId =@EmployeeId order by s.CaseId,sd.EmployeeId
       Open updateIsTimeLogFlag_Csr		  
       Fetch Next From updateIsTimeLogFlag_Csr  into @Caseid,@ScheduleId,@ScheduleDetailId,@EmployeeId
	   While @@FETCH_STATUS=0
       BEGIN
         If Exists ( select Distinct tld.Id  From Common.TimeLog As TL
		             Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
		             Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id 
		             where SystemId=@Caseid and EmployeeId=@EmployeeId 
		            )
	     Begin 
          update WorkFlow.ScheduleDetailNew set IsTimeLocked=1 where  EmployeeId=@EmployeeId and Id=@ScheduleDetailId and MasterId=@ScheduleId
	     END 
	     ELSE
	     BEGIN 
		    update WorkFlow.ScheduleDetailNew set IsTimeLocked=0 where  EmployeeId=@EmployeeId and Id=@ScheduleDetailId and MasterId=@ScheduleId
	     END 

         Fetch Next From updateIsTimeLogFlag_Csr  into  @Caseid,@ScheduleId,@ScheduleDetailId,@EmployeeId
         end
         Close updateIsTimeLogFlag_Csr
         Deallocate updateIsTimeLogFlag_Csr
    Fetch Next From MigrationIsTimeLogFlag_Csr  into  @Caseid,@EmployeeId
    end
    Close MigrationIsTimeLogFlag_Csr
    Deallocate MigrationIsTimeLogFlag_Csr

--===================
      Commit Transaction
	  End Try
	  Begin Catch
	  Declare @ErrorMessage Nvarchar(4000)=error_message();
	  Rollback
	    select @ErrorMessage
	  End Catch
 --==================
end 
--===============
GO

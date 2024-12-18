USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_updateIsTimeLogFlag]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--========================================================================20 ==================================================================
CREATE Procedure [dbo].[sp_updateIsTimeLogFlag]   -- exec  sp_updateIsTimeLogFlag '99B96CA5-3F42-4176-BE4C-BEFAB9ED3CEB','CC51AC0E-6226-4965-A22F-40FFC6F43D43'
 @Caseid Nvarchar(max),
 @EmployeeId uniqueidentifier
 as
 begin 
  --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================
    Declare @ScheduleId  uniqueidentifier,
	@ScheduleDetailId uniqueidentifier
       Declare updateIsTimeLogFlag_Csr Cursor For  
       select s.CaseId,s.id as ScheduleId, sd.id as ScheduleDetailId,sd.EmployeeId  from WorkFlow.ScheduleNew s (NOLOCK)
	   inner join WorkFlow.ScheduleDetailNew sd (NOLOCK) on sd.MasterId=s.Id where 
	   s.CaseId in ((Select items From [dbo].[SplitToTable] (@Caseid,','))) and 
	   sd.EmployeeId =@EmployeeId order by s.CaseId,sd.EmployeeId
       Open updateIsTimeLogFlag_Csr		  
       Fetch Next From updateIsTimeLogFlag_Csr  into @Caseid,@ScheduleId,@ScheduleDetailId,@EmployeeId
	   While @@FETCH_STATUS=0
       BEGIN
         If Exists ( select Distinct tld.Id  From Common.TimeLog As TL (NOLOCK)
		             Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId 
		             Inner Join Common.TimeLogDetail As TLD (NOLOCK) On TLD.MasterId=TL.Id 
		             where SystemId=@Caseid and EmployeeId=@EmployeeId and tld.Duration <> '00:00:00.0000000'
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

--===================
      Commit Transaction
	  End Try
	  Begin Catch
	  Declare @ErrorMessage Nvarchar(4000)=error_message();
	  Rollback
	    select @ErrorMessage
	  End Catch
 --==================
 Exec   [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmployeeId
end 
GO

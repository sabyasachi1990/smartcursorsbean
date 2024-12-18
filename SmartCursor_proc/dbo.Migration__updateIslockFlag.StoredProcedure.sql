USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration__updateIslockFlag]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Migration__updateIslockFlag]    ----exec [dbo].[Migration__updateIslockFlag] '99B96CA5-3F42-4176-BE4C-BEFAB9ED3CEB'

 as
 begin 
  --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================

    Declare @Caseid uniqueidentifier,
	@ScheduleId  uniqueidentifier,
	@ScheduleDetailId uniqueidentifier,
	@EmployeeId uniqueidentifier

	 Declare MigrationupdateIslockFlag_Csr Cursor For  
     select distinct  s.CaseId from WorkFlow.ScheduleNew s
	 inner join WorkFlow.ScheduleDetailNew sd on sd.MasterId=s.Id 
	 order by s.CaseId
     Open MigrationupdateIslockFlag_Csr		  
     Fetch Next From MigrationupdateIslockFlag_Csr  into @Caseid
	 While @@FETCH_STATUS=0
     BEGIN

          Declare updateIslockFlag_Csr Cursor For  
          select distinct s.CaseId,s.id as ScheduleId, sd.id as ScheduleDetailId,sd.EmployeeId  from WorkFlow.ScheduleNew s
	      inner join WorkFlow.ScheduleDetailNew sd on sd.MasterId=s.Id where 
	      s.CaseId in ((Select items From [dbo].[SplitToTable] (@Caseid,',')))   order by s.CaseId
          Open updateIslockFlag_Csr		  
          Fetch Next From updateIslockFlag_Csr  into @Caseid,@ScheduleId,@ScheduleDetailId,@EmployeeId
	      While @@FETCH_STATUS=0
          BEGIN
            If Exists ( select id  from  WorkFlow.ScheduleTaskNew where CaseId=@Caseid and EmployeeId=@EmployeeId and ScheduleDetailId=@ScheduleDetailId)
	        Begin 
             update WorkFlow.ScheduleDetailNew set IsLocked=1 where  EmployeeId=@EmployeeId and Id=@ScheduleDetailId and MasterId=@ScheduleId
	        END 
	        ELSE
	        BEGIN 
		       update WorkFlow.ScheduleDetailNew set IsLocked=0 where  EmployeeId=@EmployeeId and Id=@ScheduleDetailId and MasterId=@ScheduleId
	        END 
	      
         Fetch Next From updateIslockFlag_Csr  into  @Caseid,@ScheduleId,@ScheduleDetailId,@EmployeeId
       end
       Close updateIslockFlag_Csr
       Deallocate updateIslockFlag_Csr
   Fetch Next From MigrationupdateIslockFlag_Csr  into  @Caseid
   end
   Close MigrationupdateIslockFlag_Csr
   Deallocate MigrationupdateIslockFlag_Csr
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
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_updateEmployeedeptIsLockLogFlag]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Migration_updateEmployeedeptIsLockLogFlag]   -- exec  [dbo].[Migration_updateEmployeedeptIsLockLogFlag] 'd7d52662-dea5-4f98-9aea-8d3d3ec63299','CC51AC0E-6226-4965-A22F-40FFC6F43D43'
 as
 begin 
 --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================
    -- declare @Employee Table (Id uniqueidentifier)
    -- insert into @Employee 
    --select distinct(Id) from Common.Employee where Id in ((Select Cast(items As uniqueidentifier) From SplitToTable(@EmployeeId,',')))



      Declare @EmployeeId uniqueidentifier,
	  @EmpId  uniqueidentifier,
	  @DepartmentId uniqueidentifier,
	  @DesignationId uniqueidentifier,
	  @Level int,
	  @ChargeOutRate nvarchar(512)

	Declare MigrationEmployeedeptIsLock_Csr Cursor For  ----========= geting employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate
    select distinct  EmployeeId
	FROM HR.EmployeeDepartment order by EmployeeId
    Open MigrationEmployeedeptIsLock_Csr		  
    Fetch Next From MigrationEmployeedeptIsLock_Csr  into @EmployeeId
	While @@FETCH_STATUS=0
    BEGIN

       Declare EmployeedeptIsLock_Csr Cursor For  ----========= geting employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate
       select distinct  EmployeeId,DepartmentId,DepartmentDesignationId,isnull(LevelRank,0) LevelRank, isnull(ChargeOutRate,0) as ChargeOutRate
	   FROM HR.EmployeeDepartment WHERE EmployeeId IN(Select items  From SplitToTable(@EmployeeId,',')) order by EmployeeId
       Open EmployeedeptIsLock_Csr		  
       Fetch Next From EmployeedeptIsLock_Csr  into @EmpId,@DepartmentId,@DesignationId,@Level,@ChargeOutRate
	   While @@FETCH_STATUS=0
       BEGIN
	    --======================================= Checking employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate
         If Exists ( 
		             select Distinct  EmployeeId from WorkFlow.ScheduleDetailNew where EmployeeId=@EmpId and DepartmentId=@DepartmentId and DesignationId=@DesignationId and 
                     ISNULL(level,0)=@level and isnull(ChargeoutRate,0)=cast(@ChargeOutRate as decimal(28,9))
					 union all
					 select Distinct EmployeeId from WorkFlow.ScheduleTaskNew where EmployeeId=@EmpId and DepartmentId=@DepartmentId and DesignationId=@DesignationId 
					 and ISNULL(level,0)=@level
					 and isnull(ChargeoutRate,0)=cast(@ChargeOutRate as decimal(28,9))
					 UNION ALL
					 SELECT Distinct TL.Id  From Common.TimeLog As TL 
					 Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
					 inner join Common.TimeLogDetail T on T.MasterId=tl.Id
                     WHERE TLI.SystemId IS NOT NULL AND TL.EmployeeId=@EmpId and DepartmentId=@DepartmentId and DesignationId=@DesignationId and 
                     ISNULL(level,0)=@level  and isnull(ChargeoutRate,0)=cast(@ChargeOutRate as decimal(28,9 ))
		            )
	     Begin 
		  --======================================= update IsLocked=1 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate
               update HR.EmployeeDepartment set IsLocked=1  where EmployeeId=@EmpId and DepartmentId=@DepartmentId
			   and DepartmentDesignationId=@DesignationId and ISNULL(LevelRank,0)=@level and isnull(ChargeoutRate,0)=@ChargeOutRate
	     END 
	     ELSE
	     BEGIN 
		 	  --======================================= update IsLocked=0 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate
               update HR.EmployeeDepartment set IsLocked=0 where EmployeeId=@EmpId and DepartmentId=@DepartmentId
			   and DepartmentDesignationId=@DesignationId and ISNULL(LevelRank,0)=@level and isnull(ChargeoutRate,0)=@ChargeOutRate
	     END 
		 update HR.EmployeeDepartment set IsLocked=1 where EffectiveTo is not null or  EffectiveTo=''  and EmployeeId=@EmpId
        Fetch Next From EmployeedeptIsLock_Csr  into  @EmpId,@DepartmentId,@DesignationId,@Level,@ChargeOutRate
        end
		   
        Close EmployeedeptIsLock_Csr
        Deallocate EmployeedeptIsLock_Csr
  Fetch Next From MigrationEmployeedeptIsLock_Csr  into @EmployeeId
  end
  Close MigrationEmployeedeptIsLock_Csr
  Deallocate MigrationEmployeedeptIsLock_Csr
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

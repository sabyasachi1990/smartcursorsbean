USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_UpdateTimeLogDetailChargeoutRate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--==========================================================================================================1=======================================







	
	---===================================================================== 5th ==========================================================================
create procedure  [dbo].[Migration_UpdateTimeLogDetailChargeoutRate] -- Exec [dbo].[Migration_UpdateTimeLogDetailChargeoutRate]
as
Begin
 --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================

 ----========================== Update Total TimeLogDetail  ChargeoutRate is null  Records 94829 --===============================================

		  update tld set tld.ChargeoutRate=HR.ChargeOutRate,tld.DepartmentId=hr.DepartmentId,tld.DesignationId=hr.DepartmentDesignationId ,TLD.Level=HR.LevelRank 
		  From Common.TimeLog As TL
		  Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
		  Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
		  left join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId and convert( date,tld.date) between convert( date,hr.EffectiveFrom)
		  and  convert(date,isnull(hr.EffectiveTo,DateAdd(YYYY,10,GETDATE())))
		  Where  tli.SystemId is not null --and tld.ChargeoutRate is null ---94829


		  
		 update tl set  tl.DepartmentId=hr.DepartmentId ,tl.DesignationId=hr.DepartmentDesignationId,
           tl.Level=hr.LevelRank,tl.ChargeoutRate=cast(hr.ChargeOutRate as decimal(28,9))
            from  WorkFlow.ScheduleTaskNew tl
            inner join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId  
			and  convert(date,tl.StartDate) between convert( date,hr.EffectiveFrom) and  convert(date,isnull(hr.EffectiveTo,DateAdd(YYYY,10,GETDATE())))


      Commit Transaction
	  End Try
	  Begin Catch
	  Declare @ErrorMessage Nvarchar(4000)=error_message();
	  Rollback
	    select @ErrorMessage
	  End Catch
 --==================
 END 

		
--=========================================================== 5th===========================================================================================



 
GO

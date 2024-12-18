USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpadetDeptdesgChargeoutRate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--========================================================================19 ==================================================================
 CREATE Procedure [dbo].[SP_UpadetDeptdesgChargeoutRate]    
 --exec  [dbo].[SP_UpadetDeptdesgChargeoutRate]  'EB68F535-F836-4503-B94D-548E03B5F27B','D99B052E-D62C-4247-A8B7-8DD015849230','FA83CC72-C80F-487F-BF91-4870F6499ACF','2019-03-15 00:00:00.0000000',80
 @EmployeeId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @DesignationId uniqueidentifier,
 @Level nvarchar(5) ,
 @StartDate DATE,
 @ChargeoutRate decimal(28,9)
 as
 BEGIN 
  --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================

		 update WorkFlow.ScheduleTaskNew  set  DepartmentId=@DepartmentId,DesignationId=@DesignationId,
		 --Level=isnull( @Level,'NULL')
		  Level= case when @Level='Null' then null else @Level end 
		  ,ChargeoutRate=@ChargeoutRate
		 WHERE EmployeeId=@EmployeeId 
		 AND convert(date,StartDate)>= CONVERT (DATE,@StartDate)  

		 UPDATE T SET t.DepartmentId=@DepartmentId,t.DesignationId=@DesignationId,T.ChargeoutRate=@ChargeoutRate , 
		 --T.LEVEL=isnull( @Level,'NULL') 
		 	 T.LEVEL= case when @Level='Null' then null else @Level end  
		  FROM Common.TimeLogDetail T (NOLOCK)
         WHERE T.MasterId IN ( SELECT Distinct TL.Id  From Common.TimeLog As TL (NOLOCK) Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId 
         WHERE TLI.SystemId IS NOT NULL AND TL.EmployeeId=@EmployeeId )
	     AND convert(date,T.Date) >=  CONVERT (DATE,@StartDate)
		 
  --       select  DepartmentId=@DepartmentId,DesignationId=@DesignationId,ChargeoutRate=@ChargeoutRate from   WorkFlow.ScheduleTaskNew  
	 --   WHERE EmployeeId=@EmployeeId 
		----and DepartmentId=@DepartmentId and DesignationId=@DesignationId and ChargeoutRate=@ChargeoutRate
		--AND convert(date,StartDate)>= CONVERT (DATE,@StartDate) 

		
		  --select  t.DepartmentId=@DepartmentId,t.DesignationId=@DesignationId,T.ChargeoutRate=@ChargeoutRate    FROM Common.TimeLogDetail T
    --     WHERE T.MasterId IN ( SELECT Distinct TL.Id  From Common.TimeLog As TL Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
    --     WHERE TLI.SystemId IS NOT NULL AND TL.EmployeeId=@EmployeeId )
	   --  AND convert(date,T.Date) >=  CONVERT (DATE,@StartDate)
 	--===================
      Commit Transaction
	  End Try
	  Begin Catch
	  Declare @ErrorMessage Nvarchar(4000)=error_message();
	  Rollback
	    select @ErrorMessage
	  End Catch
 --==================   
END

GO

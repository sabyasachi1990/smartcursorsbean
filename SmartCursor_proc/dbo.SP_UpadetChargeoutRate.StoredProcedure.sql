USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpadetChargeoutRate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
 CREATE Procedure [dbo].[SP_UpadetChargeoutRate]    --exec  SP_UpadetChargeoutRate 'EB68F535-F836-4503-B94D-548E03B5F27B','2018-06-17 00:00:00.0000000','2018-06-30 00:00:00.0000000',80
 @EmployeeId uniqueidentifier,
 @FromDate DATE,
 @ToDate VARCHAR(200),
 @ChargeoutRate decimal(28,9),
 @OriginalChargeOutRate decimal(28,9),
 @DepartmentId uniqueidentifier,
 @DesignationId uniqueidentifier,
 @Level nvarchar(5)

 as
 BEGIN 
  --==================
   BEGIN TRANSACTION
   BEGIN TRY 
   --================
  --Declare @EmployeeId uniqueidentifier='EB68F535-F836-4503-B94D-548E03B5F27B',
  --@FromDate date='2018-06-17 00:00:00.0000000',
  ----@ToDate date='2018-06-30 00:00:00.0000000',
  --@ToDate date=NULL,
  --@ChargeoutRate decimal(28,9)=100

       IF (@ToDate='NULL' OR @ToDate IS NULL OR @ToDate=NULL  )
	BEGIN 
        Update WorkFlow.ScheduleTaskNew  set ChargeoutRate=@ChargeoutRate 
	    WHERE EmployeeId=@EmployeeId AND convert(date,StartDate)>= CONVERT (DATE,@FromDate)  
 	    
        UPDATE T SET T.ChargeoutRate=@ChargeoutRate    FROM Common.TimeLogDetail T (NOLOCK)
        WHERE T.MasterId IN ( SELECT Distinct TL.Id  From Common.TimeLog As TL (NOLOCK) Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId 
        WHERE TLI.SystemId IS NOT NULL AND TL.EmployeeId=@EmployeeId )
	    AND convert(date,T.Date)>= CONVERT (DATE,@FromDate)

		Update WorkFlow.ScheduleDetailNew  set ChargeoutRate=@ChargeoutRate 
	    WHERE EmployeeId=@EmployeeId AND DepartmentId=@DepartmentId and DesignationId=@DesignationId and isnull(ChargeoutRate,0)=isnull(@OriginalChargeOutRate,0)
		 		 and  isnull(level,0)=isnull( Case when @Level='NUll'THEN NULL ELSE @Level END ,0  )

	End
    ELSE 
    BEGIN 
		  Update WorkFlow.ScheduleTaskNew  set ChargeoutRate=@ChargeoutRate 
	      WHERE EmployeeId=@EmployeeId AND convert(date,StartDate) Between  CONVERT (DATE,@FromDate) and CONVERT (DATE,@ToDate)   
 	    
         UPDATE T SET T.ChargeoutRate=@ChargeoutRate    FROM Common.TimeLogDetail T (NOLOCK)
         WHERE T.MasterId IN ( SELECT Distinct TL.Id  From Common.TimeLog As TL (NOLOCK) Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId 
         WHERE TLI.SystemId IS NOT NULL AND TL.EmployeeId=@EmployeeId )
	     AND convert(date,T.Date) Between  CONVERT (DATE,@FromDate) and CONVERT (DATE,@ToDate) 
		 
	     Update WorkFlow.ScheduleDetailNew  set ChargeoutRate=@ChargeoutRate 
	     WHERE EmployeeId=@EmployeeId AND DepartmentId=@DepartmentId and DesignationId=@DesignationId and isnull(ChargeoutRate,0)=isnull(@OriginalChargeOutRate,0)
		 and  isnull(level,0)=isnull( Case when @Level='NUll'THEN NULL ELSE @Level END ,0  )


		 
	END
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

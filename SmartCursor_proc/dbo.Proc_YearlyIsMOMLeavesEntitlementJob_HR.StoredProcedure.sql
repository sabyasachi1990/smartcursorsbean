USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_YearlyIsMOMLeavesEntitlementJob_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_YearlyIsMOMLeavesEntitlementJob_HR]	
AS 
Begin   
BEGIN TRANSACTION --1
BEGIN TRY --2

Declare @StartTime Datetime2(7)=(getdate())
        Declare @Getdate DateTime2=Getdate()
		create Table #UnpaidinfantcareleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
		create Table #PaternityleavesType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
		create Table #ChildcareleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
		create Table #MaternityleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
        CREATE TABLE #IsMOMLeaves (S_No INT Identity(1, 1), CompanyId BIGINT,LeaveTypeId UNIQUEIDENTIFIER,  LeaveType NVARCHAR(200), EntitlementType NVARCHAR(200))
       	CREATE TABLE  #AllCompanyHRSettings (S_No INT Identity(1, 1), CompanyId BIGINT, HrsettingId UNIQUEIDENTIFIER, HrsettingDetailId UNIQUEIDENTIFIER, StartDate DATETIME, EndDate DATETIME)
	    CREATE TABLE  #AllPreviousPeriodEmployees  (S_No INT Identity(1, 1), EmpId UNIQUEIDENTIFIER, LTypeId UNIQUEIDENTIFIER, IsEnableLeaveRecommender BIT , [IsNotRequiredRecommender] BIT , [IsNotRequiredApprover] BIT )
	--====================Here Update LeaveEntitlementstauts 2 BASED ON Enddate base  =============
		UPDATE [HR].[LeaveEntitlement]
		SET STATUS = 2
		--, [EntitlementStatus] = 2
		WHERE [HrSettingDetaiId] IN (
				SELECT Id
				FROM [Common].[HRSettingdetails] (NOLOCK)
				WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)
				)
    --======================INSERT Previous PeriodS Employees FROM [HR].[LeaveEntitlement] TABLE =========================================
	    INSERT INTO #AllPreviousPeriodEmployees
		SELECT [EmployeeId], [LeaveTypeId], [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover]
		FROM [HR].[LeaveEntitlement] (NOLOCK)
		WHERE [HrSettingDetaiId] IN (
				SELECT Id
				FROM [Common].[HRSettingdetails] (NOLOCK)
			    WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)
				)
	--======================INSERT Previous PeriodS Employees FROM [HR].[LeaveEntitlement] TABLE =========================================
        INSERT INTO #AllCompanyHRSettings
		SELECT HRS.CompanyId, HRS.Id, HRSD.ID, HRSD.StartDate, HRSD.EndDate
		FROM [Common].[HRSettings] HRS (NOLOCK)
		INNER JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.[MasterId]
		WHERE convert(DATE, HRSD.[StartDate]) = convert(DATE, GETDATE())

	 --================================ Insert IsMOMLeaves============================================
	    INSERT INTO #IsMOMLeaves
		SELECT DISTINCT LT.CompanyId,LT.ID,  LT.Name, LT.EntitlementType
		FROM [HR].[LeaveType] LT (NOLOCK)
		WHERE LT.STATUS = 1 AND ismom=1

	  --================================ 1.Insert ChildcareleaveType============================================
			 	   --- (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)
		 Insert into #ChildcareleaveType
	     select jj.EmployeeId,jj.Days,a.CompanyId from 
	     (
	       select EmployeeId,Days from 
	       (
	  	   select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	  	   (
               select DISTINCT EmployeeId,6 AS Days from hr.FamilyDetails where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 AND IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') and DateOfBirth is not null
	  	     Union all
               select DISTINCT EmployeeId,2 as Days from hr.FamilyDetails where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0)) Between 7 and 12 AND IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') and DateOfBirth is not null
			Union all
	           select DISTINCT EmployeeId,2 AS Days from hr.FamilyDetails where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 AND (IDTypeNew<>'NRIC(Pink)' or IDTypeNew is null or IDTypeNew=' ') 
			   and DateOfBirth is not null
	     
	  	   )hh 
	       )gg where rank=1 
	     )jj
	      inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	      WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 and a.Gender in ('Male','Female') 

	     --========================================2.Insert 'Maternity leave'============================================================= 
	                  ---=============================(Female  ,'NRICPink' ) (Gender,IdType)
	        Insert into #MaternityleaveType
	        select A.Id AS EmployeeId,case when A.IdType='NRIC(Pink)' AND B.EmployeeId IS NOT NULL THEN  112 when A.IdType='NRIC(Pink)' AND B.EmployeeId IS  NULL THEN  84 else 56 end AS Days, a.CompanyId 
			from Common.Employee A (NOLOCK)
			      left join 
	        (
	       select DISTINCT EmployeeId from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	       AND IDTypeNew='NRIC(Pink)' 
		   )B ON B.EmployeeId=A.Id
	        where  A.Gender='Female' AND  A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 

		--========================================3.'Paternity leaves'=============================================================
                	--======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)
            Insert into #PaternityleavesType
	        select jj.EmployeeId,jj.Days,a.CompanyId from 
	        (
	          select EmployeeId,Days from 
	          (
	       	 select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	       	 (
                  select DISTINCT EmployeeId,14 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')AND IDTypeNew='NRIC(Pink)'
	       	 )hh 
	          )gg where rank=1 
	        )jj
	        inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	        WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 
	        AND a.Gender='Male'

		   --========================================4.'Unpaid infant care leave'=============================================================
	       	 ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)
	         Insert into #UnpaidinfantcareleaveType
	         select jj.EmployeeId,jj.Days,a.CompanyId from 
	         (
	           select EmployeeId,Days from 
	           (
	  	       select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	  	       (
                   select DISTINCT EmployeeId,12 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')AND IDTypeNew='NRIC(Pink)'
	  	         AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<2 
	  	       )hh 
	           )gg where rank=1 
	         )jj
	         inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	         WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 


           --=========================================Insert into [HR].[LeaveEntitlement] all ismom Leaves =============================
		   INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Prorated, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	   select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HrsettingDetailId ,1,a.Days,a.Days,a.Days,a.Days,P.IsEnableLeaveRecommender,P.IsNotRequiredRecommender,P.IsNotRequiredRecommender
		   from  #ChildcareleaveType A
		   INNER JOIN #IsMOMLeaves B ON B.CompanyId=A.CompanyId
		   INNER JOIN #AllCompanyHRSettings c on c.CompanyId=a.CompanyId
		   INNER JOIN #AllPreviousPeriodEmployees P on P.EmpId=a.EmployeeId AND P.LTypeId=B.LeaveTypeId
		   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HrsettingDetailId
		   WHERE B.LeaveType='Childcare leave' AND D.ID IS NULL 

		   INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], Prorated,[IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	   select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HrsettingDetailId ,1,a.Days,a.Days,a.Days,a.Days,P.IsEnableLeaveRecommender,P.IsNotRequiredRecommender,P.IsNotRequiredRecommender
		   from  #MaternityleaveType A
		   INNER JOIN #IsMOMLeaves B ON B.CompanyId=A.CompanyId
		   INNER JOIN #AllCompanyHRSettings c on c.CompanyId=a.CompanyId
		   INNER JOIN #AllPreviousPeriodEmployees P on P.EmpId=a.EmployeeId AND P.LTypeId=B.LeaveTypeId
		   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HrsettingDetailId
		   WHERE B.LeaveType='Maternity leave' AND D.ID IS NULL 

		   INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], Prorated,[IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	   select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HrsettingDetailId ,1,a.Days,a.Days,a.Days,a.Days,P.IsEnableLeaveRecommender,P.IsNotRequiredRecommender,P.IsNotRequiredRecommender
		   from  #PaternityleavesType A
		   INNER JOIN #IsMOMLeaves B ON B.CompanyId=A.CompanyId
		   INNER JOIN #AllCompanyHRSettings c on c.CompanyId=a.CompanyId
		   INNER JOIN #AllPreviousPeriodEmployees P on P.EmpId=a.EmployeeId AND P.LTypeId=B.LeaveTypeId
		   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HrsettingDetailId
		   WHERE B.LeaveType='Paternity leaves' AND D.ID IS NULL 

		   	INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Prorated, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	   select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HrsettingDetailId ,1,a.Days,a.Days,a.Days,a.Days,P.IsEnableLeaveRecommender,P.IsNotRequiredRecommender,P.IsNotRequiredRecommender
		   from  #UnpaidinfantcareleaveType A
		   INNER JOIN #IsMOMLeaves B ON B.CompanyId=A.CompanyId
		   INNER JOIN #AllCompanyHRSettings c on c.CompanyId=a.CompanyId
		   INNER JOIN #AllPreviousPeriodEmployees P on P.EmpId=a.EmployeeId AND P.LTypeId=B.LeaveTypeId
		   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HrsettingDetailId
		   WHERE B.LeaveType='Unpaid infant care leave' AND D.ID IS NULL 


	DROP TABLE #UnpaidinfantcareleaveType  
	DROP TABLE #PaternityleavesType  
	DROP TABLE #ChildcareleaveType  
	DROP TABLE #MaternityleaveType  
    DROP TABLE #IsMOMLeaves 
   	DROP TABLE  #AllCompanyHRSettings 
    DROP TABLE  #AllPreviousPeriodEmployees

COMMIT TRANSACTION --1
END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH


Insert into Common.JobStatus (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','MOM Leave Entitlement Insertion','Job','MOM LeaveEntitlement Insert',@StartTime,getdate(),null,null,'Completed')



END


GO

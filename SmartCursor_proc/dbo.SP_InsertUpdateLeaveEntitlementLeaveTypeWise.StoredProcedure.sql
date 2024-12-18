USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertUpdateLeaveEntitlementLeaveTypeWise]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	--Alter Table [HR].[LeaveType] Add IsMOM bit
	--Alter Table [HR].[LeaveType] drop column IsMOM 
	--Declare @EmployeeId  uniqueidentifier='2F2574CE-C8BB-4B8D-82C3-32EB32CBE4E8'      ---'3493FA02-4669-FC64-0C75-A7B638A1BE60' -----'2F2574CE-C8BB-4B8D-82C3-32EB32CBE4E8'
	--Declare @CompanyId  bigint=1

CREATE Procedure [dbo].[SP_InsertUpdateLeaveEntitlementLeaveTypeWise]  --Eexc SP_InsertUpdateLeaveEntitlementLeaveTypeWise 'E53973FE-595F-49B3-8D3A-C92DE7A37440' ,1
@LeaveTypeId uniqueidentifier,
@CompanyId bigint
AS
Begin
BEGIN TRANSACTION --1
BEGIN TRY --1
	Declare @Getdate DateTime2=Getdate()
	   --=================================================Create Temp Table Based on HRSettingdetails=================================
	  create Table #HRSettingdetails  (CompanyId bigint,HRSettingdetailsId uniqueidentifier,StartDate datetime2,EndDate datetime2)
	  --==========================Here Getting StartDate and EndDate and HRSettingdetailsId  Based on Company and CurrentDate===================================
	  Insert into #HRSettingdetails
	  select  A.CompanyId,b.id as HRSettingdetailsId,b.StartDate,b.EndDate
	  from [Common].[HRSettings] A (NOLOCK)
	  Inner join [Common].[HRSettingdetails] B (NOLOCK) ON B.MasterId=A.Id
	  Where  @Getdate between b.StartDate and b.EndDate  and a.CompanyId=@CompanyId

	  Declare @LeaveTypeName Nvarchar(200)=(select top 1 Name from [HR].[LeaveType] (NOLOCK) where  IsMOM=1 and CompanyId=@CompanyId and id=@LeaveTypeId)
	  Declare @EnableLeaveRecommender bit=(select top 1 EnableLeaveRecommender from [HR].[LeaveType] (NOLOCK) where  IsMOM=1 and CompanyId=@CompanyId and id=@LeaveTypeId)

--		   --========================================1.Check Childcare leave=============================================================
--	---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
       IF  (@LeaveTypeName ='Childcare leave')
       Begin
        ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #ChildcareleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
	     ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
	     Insert into #ChildcareleaveType
	     select jj.EmployeeId,jj.Days,a.CompanyId from 
	     (
	       select EmployeeId,Days from 
	       (
	    	 select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	    	 (
               select DISTINCT EmployeeId,6 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 AND IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') and DateOfBirth is not null
	    	   --and EmployeeId=@EmployeeId
	    	   Union all
               select DISTINCT EmployeeId,2 as Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0)) Between 7 and 12 AND IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') and DateOfBirth is not null
	    	   --and EmployeeId=@EmployeeId
			   Union all
	           select DISTINCT EmployeeId,2 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 AND (IDTypeNew<>'NRIC(Pink)' or IDTypeNew is null or IDTypeNew=' ') 
			   and DateOfBirth is not null
	    	 )hh 
	       )gg where rank=1 
	     )jj
	     inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	     WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1  and a.Gender in ('Male','Female')  and a.CompanyId=@CompanyId
	      ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #ChildcareleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200))
       
	     --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================
	     Insert into #ChildcareleaveTypeId
         select CompanyId,id as LeaveTypeId,Name from 
	     (
	       select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank
	       from [HR].[LeaveType] (NOLOCK) where Name='Childcare leave'  and IsMOM=1 and CompanyId=@CompanyId and id=@LeaveTypeId
	     )gg where Rank=1
       
	    INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Total,Prorated,FutureProrated,CarryForwardDays,Adjustment, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	 select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,@EnableLeaveRecommender,case when gg.idNew is null then 1 else 0 end ,case when hh.idNew is null then 1 else 0 end
			   from  #ChildcareleaveType A
	    	   INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=A.CompanyId
	    	   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
	    	   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId
			   	 Left join   
				   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Recommender' ) gg on gg.idNew=a.EmployeeId
		       left join 
		 	   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Approver' ) hh on hh.idNew=a.EmployeeId


	    	   WHERE D.ID IS NULL 

	   	    update a set a.status=2 ,a.[EntitlementStatus]=2 
	        from   [HR].[LeaveEntitlement] A (NOLOCK)
	        INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId
	        INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId
	        LEFT JOIN  #ChildcareleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId
	        where a.LeaveTypeId=@LeaveTypeId and d.EmployeeId is null 
			
	       update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),
		   d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days
		   from  #ChildcareleaveType A
		   INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=A.CompanyId
		   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
		   inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId

	      drop table  #ChildcareleaveType
	      drop table  #ChildcareleaveTypeId
       END  
	--		--========================================2.'Maternity leave'============================================================= 
--	    ---=============================(Female  ,'NRICPink' ) (Gender,IdType)============================================== 
       IF  (@LeaveTypeName ='Maternity leave')
       Begin
	         ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #MaternityleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
	     ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
	     Insert into #MaternityleaveType
	     select A.Id AS EmployeeId,case when A.IdType='NRIC(Pink)' AND B.EmployeeId IS NOT NULL THEN  112 when A.IdType='NRIC(Pink)' AND B.EmployeeId IS  NULL THEN  84 else 56 end AS Days, a.CompanyId 
		 from Common.Employee A (NOLOCK)
		     left join 
	        (
	       select DISTINCT EmployeeId from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	       AND IDTypeNew='NRIC(Pink)' 
		   )B ON B.EmployeeId=A.Id
	     where  A.Gender='Female' AND  A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1  and a.CompanyId=@CompanyId --and Id=@EmployeeId
	      ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #MaternityleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200))
       
	     --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================
	     Insert into #MaternityleaveTypeId
         select CompanyId,id as LeaveTypeId,Name from 
	     (
	       select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank
	       from [HR].[LeaveType] (NOLOCK) where Name='Maternity leave' and CompanyId=@CompanyId and IsMOM=1  and id=@LeaveTypeId
	     )gg where Rank=1
       
	    INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Total,Prorated,FutureProrated,CarryForwardDays,Adjustment, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	 select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,@EnableLeaveRecommender,case when gg.idNew is null then 1 else 0 end ,case when hh.idNew is null then 1 else 0 end
			   from  #MaternityleaveType A
	    	   INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=A.CompanyId
	    	   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
	    	   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId
			   			   	 Left join   
				   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Recommender' ) gg on gg.idNew=a.EmployeeId
		       left join 
		 	   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Approver' ) hh on hh.idNew=a.EmployeeId
	    	   WHERE D.ID IS NULL 

	   		 update a set a.status=2 ,a.[EntitlementStatus]=2 
	        from   [HR].[LeaveEntitlement] A (NOLOCK)
	        INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId
	        INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId
	        LEFT JOIN  #MaternityleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId
	        where a.LeaveTypeId=@LeaveTypeId  and d.EmployeeId is null 

	       update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),
		   d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days
		   from  #MaternityleaveType A
		   INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=A.CompanyId
		   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
		   inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId


	       drop table  #MaternityleaveType
	       drop table  #MaternityleaveTypeId
       
       END
--		--========================================3.'Paternity leaves'=============================================================
--		--======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================
       IF  (@LeaveTypeName ='Paternity leaves')
       Begin
	    	   	     ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #PaternityleavesType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
	     ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
	     Insert into #PaternityleavesType
	     select jj.EmployeeId,jj.Days,a.CompanyId from 
	     (
	       select EmployeeId,Days from 
	       (
	    	 select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	    	 (
               select DISTINCT EmployeeId,14 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')AND IDTypeNew='NRIC(Pink)'
	    	   ----and EmployeeId=@EmployeeId
	    	 )hh 
	       )gg where rank=1 
	     )jj
	     inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	     WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 and a.CompanyId=@CompanyId
	     AND a.Gender='Male'
	      ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #PaternityleavesTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200))
       
	     --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================
	     Insert into #PaternityleavesTypeId
         select CompanyId,id as LeaveTypeId,Name from 
	     (
	       select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank
	       from [HR].[LeaveType] (NOLOCK) where Name='Paternity leaves' and CompanyId=@CompanyId and IsMOM=1 and id=@LeaveTypeId
	     )gg where Rank=1
       
	    INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Total,Prorated,FutureProrated,CarryForwardDays,Adjustment, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	 select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,@EnableLeaveRecommender,case when gg.idNew is null then 1 else 0 end ,case when hh.idNew is null then 1 else 0 end
			   from  #PaternityleavesType A
	    	   INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=A.CompanyId
	    	   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
	    	   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId

			   			   	 Left join   
				   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Recommender' ) gg on gg.idNew=a.EmployeeId
		       left join 
		 	   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Approver' ) hh on hh.idNew=a.EmployeeId
	    	   WHERE D.ID IS NULL 

	   		 update a set a.status=2 ,a.[EntitlementStatus]=2 
	        from   [HR].[LeaveEntitlement] A (NOLOCK)
	        INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId
	        INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId
	        LEFT JOIN  #PaternityleavesType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId
	        where a.LeaveTypeId=@LeaveTypeId and d.EmployeeId is null 

	       update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),
		   d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days
		   from  #PaternityleavesType A
		   INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=A.CompanyId
		   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
		   inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId

	      drop table  #PaternityleavesType
	      drop table  #PaternityleavesTypeId
       END
--		--========================================4.'Unpaid infant care leave'=============================================================
--		--======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================
       IF  (@LeaveTypeName ='Unpaid infant care leave')
       Begin
	        	   	
	    	   		   	     ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #UnpaidinfantcareleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)
	     ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
	     Insert into #UnpaidinfantcareleaveType
	     select jj.EmployeeId,jj.Days,a.CompanyId from 
	     (
	       select EmployeeId,Days from 
	       (
	    	 select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from 
	    	 (
               select DISTINCT EmployeeId,6 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')AND IDTypeNew='NRIC(Pink)'
	    	   AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<2--- and EmployeeId=@EmployeeId
	    	 )hh 
	       )gg where rank=1 
	     )jj
	     inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId
	     WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1  and a.CompanyId=@CompanyId
	      ---============================================Create Temp Table Based on FamilyDetails==================================
	     create Table #UnpaidinfantcareleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200))
       
	     --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================
	     Insert into #UnpaidinfantcareleaveTypeId
         select CompanyId,id as LeaveTypeId,Name from 
	     (
	       select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank
	       from [HR].[LeaveType] (NOLOCK) where Name='Unpaid infant care leave' and CompanyId=@CompanyId and IsMOM=1 and id=@LeaveTypeId
	     )gg where Rank=1
       
	    INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Total,Prorated,FutureProrated,CarryForwardDays,Adjustment, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])
	 	 select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,@EnableLeaveRecommender,case when gg.idNew is null then 1 else 0 end ,case when hh.idNew is null then 1 else 0 end
			   from  #UnpaidinfantcareleaveType A
	    	   INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=A.CompanyId
	    	   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
	    	   LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId
			   			   	 Left join   
				   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Recommender' ) gg on gg.idNew=a.EmployeeId
		       left join 
		 	   (
	     select distinct EmployeeId as idNew from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'
         and Type='Approver' ) hh on hh.idNew=a.EmployeeId

	    	   WHERE D.ID IS NULL 

	   		update a set a.status=2 ,a.[EntitlementStatus]=2 
	        from   [HR].[LeaveEntitlement] A (NOLOCK)
	        INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId
	        INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId
	        LEFT JOIN  #UnpaidinfantcareleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId
	        where a.LeaveTypeId=@LeaveTypeId and d.EmployeeId is null 

	       update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),
		   d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days
		   from  #UnpaidinfantcareleaveType A
		   INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=A.CompanyId
		   INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId
		   inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId

	      drop table  #UnpaidinfantcareleaveType
	      drop table  #UnpaidinfantcareleaveTypeId
       END
	   drop table   #HRSettingdetails
	   ----drop table  #ChildcareleaveType
	   ----drop table  #ChildcareleaveTypeId
	   ----drop table  #MaternityleaveType
	   ----drop table  #MaternityleaveTypeId
	   ----drop table  #PaternityleavesType
	   ----drop table  #PaternityleavesTypeId
	   ----drop table  #UnpaidinfantcareleaveType
	   ----drop table  #UnpaidinfantcareleaveTypeId
COMMIT TRANSACTION --1
END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END


GO

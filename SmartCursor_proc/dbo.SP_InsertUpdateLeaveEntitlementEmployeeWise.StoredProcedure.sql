USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertUpdateLeaveEntitlementEmployeeWise]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --Alter Table [HR].[LeaveType] Add IsMOM bit  
 --Alter Table [HR].[LeaveType] drop column IsMOM   
 --Declare @EmployeeId  uniqueidentifier='2F2574CE-C8BB-4B8D-82C3-32EB32CBE4E8'      ---'3493FA02-4669-FC64-0C75-A7B638A1BE60' -----'2F2574CE-C8BB-4B8D-82C3-32EB32CBE4E8'  
 --Declare @CompanyId  bigint=1  
  
CREATE Procedure [dbo].[SP_InsertUpdateLeaveEntitlementEmployeeWise]  --ExEc SP_InsertUpdateLeaveEntitlementEmployeeWise '9CD24598-B5B2-4500-AA99-B5F351DAAFD1' ,2058  
@EmployeeId uniqueidentifier,  
@CompanyId bigint  
AS  
Begin  
BEGIN TRANSACTION --1  
BEGIN TRY --2  
  
 Declare @Getdate DateTime2=Getdate()  
  
       Declare @Recommender uniqueidentifier=  
       (  
       select top 1  EmployeeId from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'  
       and EmployeeId=@EmployeeId and Type='Recommender'   
       )  
         
         
       Declare @Approver uniqueidentifier=  
       (  
       select top 1  EmployeeId from [HR].[EmployeRecandApprovers] (NOLOCK) where ScreenName='Leaves'  
       and EmployeeId=@EmployeeId and Type='Approver'  
       )  
  
  
    --=================================================Create Temp Table Based on HRSettingdetails=================================  
   create Table #HRSettingdetails  (CompanyId bigint,HRSettingdetailsId uniqueidentifier,StartDate datetime2,EndDate datetime2)  
   --==========================Here Getting StartDate and EndDate and HRSettingdetailsId  Based on Company and CurrentDate===================================  
   Insert into #HRSettingdetails  
   select  A.CompanyId,b.id as HRSettingdetailsId,b.StartDate,b.EndDate  
   from [Common].[HRSettings] A (NOLOCK)  
   Inner join [Common].[HRSettingdetails] B (NOLOCK) ON B.MasterId=A.Id  
   Where  @Getdate between b.StartDate and b.EndDate  and a.CompanyId=@CompanyId  
  
--     --========================================1.Check Childcare leave=============================================================  
-- ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================  
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
        AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 
		--AND 
		--IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') and DateOfBirth is not null  
     and EmployeeId=@EmployeeId  
     Union all  
           select DISTINCT EmployeeId,2 as Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality!='Singapore Citizen'   
        AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0)) < 7 
		--and 12 AND IDTypeNew in ('NRIC(Pink)','NRIC(Blue)') 
		and DateOfBirth is not null  
     and EmployeeId=@EmployeeId  
     --Union all  
     --   select DISTINCT EmployeeId,2 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen'   
     --   AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<7 AND (IDTypeNew<>'NRIC(Pink)' or IDTypeNew is null or IDTypeNew=' ')   
     --and DateOfBirth is not null and EmployeeId=@EmployeeId  
   )hh   
    )gg where rank=1   
  )jj  
  inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId 
  WHERE 
  --A.IdType IS NOT NULL AND 
  a.IsWorkflowOnly = 0 and a.status=1  and a.Id=@EmployeeId and a.CompanyId=@CompanyId  
  --and (select DATEDIFF(MONTH, emp.StartDate, GETDATE()))>3
   ---============================================Create Temp Table Based on FamilyDetails==================================  
  create Table #ChildcareleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200),EnableLeaveRecommender bit )  
  
  --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================  
  Insert into #ChildcareleaveTypeId  
     select CompanyId,id as LeaveTypeId,Name,EnableLeaveRecommender from   
  (  
    select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank,EnableLeaveRecommender  
    from [HR].[LeaveType] (NOLOCK) where Name='Childcare leave'  and IsMOM=1 and CompanyId=@CompanyId and Status=1  
  )gg where Rank=1  
  
  
     INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance],Total,Prorated,FutureProrated,CarryForwardDays,Adjustment, [IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])  
    select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,EnableLeaveRecommender ,case when @Recommender is null then 1 else 0 end,case when @Approver is null then 1 else 0 end  
     from  #ChildcareleaveType A  
     INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
     WHERE D.ID IS NULL   
     
         update a set a.status=2 ,a.[EntitlementStatus]=2   
         from   [HR].[LeaveEntitlement] A (NOLOCK)  
         INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId  
         INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId  
         LEFT JOIN  #ChildcareleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId  
         where a.EmployeeId=@EmployeeId and d.EmployeeId is null   
  
  
        update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.
ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),  
     d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days  
     from  #ChildcareleaveType A  
     INNER JOIN #ChildcareleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
       
  
  
 --  --========================================2.'Maternity leave'=============================================================   
--     ---=============================(Female  ,'NRICPink' ) (Gender,IdType)==============================================   
      ---============================================Create Temp Table Based on FamilyDetails==================================  
  create Table #MaternityleaveType  (EmployeeId uniqueidentifier,Days int,CompanyId bigint)  
  ---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================  
  Insert into #MaternityleaveType  
  --select A.Id AS EmployeeId,case when  B.EmployeeId IS NOT NULL THEN  112 when A.IdType='NRIC(Pink)' AND B.EmployeeId IS  NULL THEN  84 else 56 end AS Days, a.CompanyId   
  --from Common.Employee A (NOLOCK)  
  --     left join   
  --       (  
  --      select DISTINCT EmployeeId from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen'   
  --      --AND IDTypeNew='NRIC(Pink)'   
  --   and EmployeeId=@EmployeeId  
  --   )B ON B.EmployeeId=A.Id  
  --where  A.Gender='Female' AND  A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 and a.Id=@EmployeeId and a.CompanyId=@CompanyId  

  select jj.EmployeeId,jj.Days,a.CompanyId from   
  (  
    select EmployeeId,Days from   
    (  
   select EmployeeId,Days,RANK() OVER (PARTITION BY EmployeeId ORDER BY Days DESC) AS Rank   from   
   (  
           select DISTINCT EmployeeId,112 as Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' and EmployeeId=@EmployeeId 

		   Union all  
           select DISTINCT EmployeeId,84 as Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter') AND  Nationality!='Singapore Citizen'   
     
   )hh   
    )gg where rank=1   
  )jj  
  inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId   
  WHERE
  a.IsWorkflowOnly = 0 and a.status=1 and a.Gender in ('Female') and a.Id=@EmployeeId and a.CompanyId=@CompanyId 
  --and (select DATEDIFF(MONTH, emp.StartDate, GETDATE()))>3

  --declare @Count int = (select count(*) from #MaternityleaveType)
  --if(@Count=0)
  --begin
  --Insert into #MaternityleaveType  
  --select A.Id,84,A.CompanYId  from Common.Employee A (NOLOCK) join hr.Employment as emp on A.id=emp.EmployeeId  
  --WHERE
  --a.IsWorkflowOnly = 0 and a.status=1 and a.Gender in ('Male','Female') and a.Id=@EmployeeId and a.CompanyId=@CompanyId and 
  --(select DATEDIFF(MONTH, emp.StartDate, GETDATE()))>3
  --end
   ---============================================Create Temp Table Based on FamilyDetails==================================  
  create Table #MaternityleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200),EnableLeaveRecommender bit)  
  
  --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================  
  Insert into #MaternityleaveTypeId  
     select CompanyId,id as LeaveTypeId,Name,EnableLeaveRecommender from   
  (  
    select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank,EnableLeaveRecommender  
    from [HR].[LeaveType] (NOLOCK) where Name='Maternity leave' and CompanyId=@CompanyId and IsMOM=1 and Status=1  
  )gg where Rank=1  
  
     INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], Total,
Prorated,FutureProrated,CarryForwardDays,Adjustment,[IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])  
    select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,EnableLeaveRecommender,case when @Recommender is null then 1 else 0 end,case when @Approver is null then 1 else 0 end  
     from  #MaternityleaveType A  
     INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
     WHERE D.ID IS NULL   
  
      update a set a.status=2 ,a.[EntitlementStatus]=2   
         from   [HR].[LeaveEntitlement] A (NOLOCK)  
         INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId  
         INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId  
         LEFT JOIN  #MaternityleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId  
         where a.EmployeeId=@EmployeeId and d.EmployeeId is null   
  
        update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.
ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),  
     d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days  
     from  #MaternityleaveType A  
     INNER JOIN #MaternityleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
  
--  --========================================3.'Paternity leaves'=============================================================  
--  --======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================  
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
           select DISTINCT EmployeeId,12 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')AND 
		   CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0)) < 1 and Nationality in ('Singapore Citizen')
		   --IDTypeNew='NRIC(Pink)'  
     and EmployeeId=@EmployeeId  
   )hh   
    )gg where rank=1   
  )jj  
  inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId  
  WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 and a.Id=@EmployeeId and a.CompanyId=@CompanyId  
  AND a.Gender='Male'  
   ---============================================Create Temp Table Based on FamilyDetails==================================  
  create Table #PaternityleavesTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200),EnableLeaveRecommender bit)  
  
  --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================  
  Insert into #PaternityleavesTypeId  
     select CompanyId,id as LeaveTypeId,Name,EnableLeaveRecommender from   
  (  
    select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank,EnableLeaveRecommender  
    from [HR].[LeaveType] (NOLOCK) where Name='Paternity leaves' and CompanyId=@CompanyId and IsMOM=1 and Status=1  
  )gg where Rank=1  
  
     INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], Total,
Prorated,FutureProrated,CarryForwardDays,Adjustment,[IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])  
    select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,EnableLeaveRecommender,case when @Recommender is null then 1 else 0 end,case when @Approver is null then 1 else 0 end  
     from  #PaternityleavesType A  
     INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
     WHERE D.ID IS NULL   
  
     update a set a.status=2 ,a.[EntitlementStatus]=2   
         from   [HR].[LeaveEntitlement] A (NOLOCK)  
         INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId  
         INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId  
         LEFT JOIN  #PaternityleavesType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId  
         where a.EmployeeId=@EmployeeId and d.EmployeeId is null   
  
        update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.
ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),  
     d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days  
     from  #PaternityleavesType A  
     INNER JOIN #PaternityleavesTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
  
--  --========================================4.'Unpaid infant care leave'=============================================================  
--  --======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================  
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
           select DISTINCT EmployeeId,6 AS Days from hr.FamilyDetails (NOLOCK) where  RelationShip in ('Son','Daughter')
		   and Nationality='Singapore Citizen'
		   --IDTypeNew='NRIC(Pink)'  
     AND CONVERT(int,(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0))<2 and EmployeeId=@EmployeeId  
   )hh   
    )gg where rank=1   
  )jj  
  inner join  Common.Employee A (NOLOCK) on a.id=jj.EmployeeId  
  WHERE A.IdType IS NOT NULL AND a.IsWorkflowOnly = 0 and a.status=1 and a.Id=@EmployeeId and a.CompanyId=@CompanyId  
  --and (select DATEDIFF(MONTH, emp.StartDate, GETDATE()))>3
   ---============================================Create Temp Table Based on FamilyDetails==================================  
  create Table #UnpaidinfantcareleaveTypeId  (CompanyId bigint,LeaveTypeId uniqueidentifier,Name Nvarchar(200),EnableLeaveRecommender bit )  
  
  --=================================================Insert into LeaveTypeId in Childcare leave based on company wise =========================  
  Insert into #UnpaidinfantcareleaveTypeId  
     select CompanyId,id as LeaveTypeId,Name,EnableLeaveRecommender from   
  (  
    select  CompanyId,id,Name,RANK() OVER (PARTITION BY CompanyId ORDER BY id ) AS Rank,EnableLeaveRecommender  
    from [HR].[LeaveType] (NOLOCK) where Name='Unpaid infant care leave' and CompanyId=@CompanyId and IsMOM=1 and Status=1  
  )gg where Rank=1  
  
  
     INSERT [HR].[LeaveEntitlement] ([Id], [EmployeeId], [LeaveTypeId], [AnnualleaveEntitlement], [UserCreated], [CreatedDate], [status], [startdate], [EndDate], [HRSettingDetaiId], [EntitlementStatus], [YTDLeaveBalance], [Current], [LeaveBalance], Total,
Prorated,FutureProrated,CarryForwardDays,Adjustment,[IsEnableLeaveRecommender], [IsNotRequiredRecommender], [IsNotRequiredApprover])  
    select NewId(),A.EmployeeId,B.LeaveTypeId,A.Days,'System',@Getdate,1,c.StartDate,c.EndDate,C.HRSettingdetailsId ,1,a.Days,a.Days,a.Days,a.Days,a.Days,a.Days,0,0,EnableLeaveRecommender,case when @Recommender is null then 1 else 0 end,case when @Approver is null then 1 else 0 end  
     from  #UnpaidinfantcareleaveType A  
     INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     LEFT JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
     WHERE D.ID IS NULL   
  
     update a set a.status=2 ,a.[EntitlementStatus]=2   
         from   [HR].[LeaveEntitlement] A (NOLOCK)  
         INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=@CompanyId AND A.LeaveTypeId=B.LeaveTypeId  
         INNER JOIN #HRSettingdetails c on c.CompanyId=@CompanyId and c.HRSettingdetailsId=a.HrSettingDetaiId  
         LEFT JOIN  #UnpaidinfantcareleaveType d ON  d.EmployeeId=a.EmployeeId and d.CompanyId=@CompanyId  
         where a.EmployeeId=@EmployeeId and d.EmployeeId is null   
  
        update D set d.status=1 ,d.[EntitlementStatus]=1,d.AnnualLeaveEntitlement=a.Days,d.Prorated=a.Days,d.[Current]=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0)),d.Total=isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0),d.YTDLeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),d.LeaveBalance=(isnull(a.Days,0)+isnull(d.BroughtForward,0)+isnull(d.Adjustment,0))-((isnull(d.ApprovedAndTaken,0)+isnull(d.ApprovedAndNotTaken,0))),  
     d.Adjusted = (CASE WHEN (d.Adjustment != null) THEN isnull(a.Days,0)+isnull(d.Adjustment,0) ELSE NULL END),d.CarryForwardDays=0,d.FutureProrated=a.Days  
     from  #UnpaidinfantcareleaveType A  
     INNER JOIN #UnpaidinfantcareleaveTypeId B ON B.CompanyId=A.CompanyId  
     INNER JOIN #HRSettingdetails c on c.CompanyId=a.CompanyId  
     inner JOIN [HR].[LeaveEntitlement] D (NOLOCK) ON D.EmployeeId=A.EmployeeId AND D.LeaveTypeId=B.LeaveTypeId AND D.HrSettingDetaiId=C.HRSettingdetailsId  
     
    drop table   #HRSettingdetails  
    drop table  #ChildcareleaveType  
    drop table  #ChildcareleaveTypeId  
    drop table  #MaternityleaveType  
    drop table  #MaternityleaveTypeId  
    drop table  #PaternityleavesType  
    drop table  #PaternityleavesTypeId  
    drop table  #UnpaidinfantcareleaveType  
    drop table  #UnpaidinfantcareleaveTypeId  
  
  
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

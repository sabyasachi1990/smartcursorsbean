USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_YearlyClaimsEntitlementJob_HR_MIG]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Proc_YearlyClaimsEntitlementJob_HR_MIG]   
AS  
Begin--s1  
  
  --EXEC [dbo].[Proc_YearlyClaimsEntitlementJob_HR_MIG]
DECLARE @CompanyId BIGINT  = 1437
DECLARE @HrsettingDetailId UNIQUEIDENTIFIER  
DECLARE @HrsettingId UNIQUEIDENTIFIER  
Declare @StartTime Datetime2(7)=(getdate())  
  
  
DECLARE @AllCompany_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, HrsettingId UNIQUEIDENTIFIER, HrsettingDetailId UNIQUEIDENTIFIER)  
  
Create table  #AllEmployee_Tbl  (S_No INT Identity(1, 1), EntitlementId UNIQUEIDENTIFIER, EmployeeID UNIQUEIDENTIFIER, DepartmentId UNIQUEIDENTIFIER NULL, Designationid UNIQUEIDENTIFIER NULL)  
  
Create table  #Category_Tbl  (S_No INT Identity(1, 1), ClaimItemId UNIQUEIDENTIFIER, ClaimSetuiId UNIQUEIDENTIFIER, Category NVARCHAR(200), CategoryLimit MONEY NULL, AnnualLimit MONEY NULL, TransactionLimit MONEY NULL, ApplyTo NVARCHAR(200), DepartmentId 
UNIQUEIDENTIFIER NULL, DesignationId UNIQUEIDENTIFIER NULL, Type_1 NVARCHAR(200))  
  
Create table  #AllDesignation_Tb  (Designationid UNIQUEIDENTIFIER NULL)  
  
  
DECLARE @CompanyCount INT  
DECLARE @RecCount INT  
DECLARE @CategoryCount INT  
  
  
BEGIN TRANSACTION--s2  
 BEGIN TRY--s3  
  
  
--SELECT * FROM  
--update   
--[HR].[EmployeeClaimsEntitlementDetail] WITH (ROWLOCK)   
--set status=2  
--where [HrSettingDetaiId] in (SELECT Id    
--    FROM [Common].[HRSettingdetails] (NOLOCK)    
--    WHERE convert(DATE, [EndDate]) = dateadd(day, datediff(day, 4, GETDATE()), 0) 
--	and MasterId in (select Id from Common.HRSettings where  CompanyId=1437))   
  
  
INSERT INTO @AllCompany_Tbl  
  
SELECT HRS.CompanyId, HRS.Id, HRSD.ID  
FROM [Common].[HRSettings] HRS (NOLOCK)  
JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.[MasterId]  
WHERE convert(DATE, [EndDate]) = '2025-07-31 00:00:00.0000000'
and HRSD.MasterId in (select Id from Common.HRSettings where  CompanyId=1437)

--SELECT dateadd(day, datediff(day, 4, GETDATE()), 0)
--AND (select year(convert(DATE, HRSD.[StartDate] ))) = (select Year(convert(DATE, GETDATE()))) 
  
SET @CompanyCount = (  
  SELECT Count(*)  
  FROM @AllCompany_Tbl  
  )  
SET @RecCount = 1  
  
--IF EXISTS @CompanyCount  
--BEGIN --M1  
 WHILE @CompanyCount >= @RecCount  
 BEGIN --1  
  SELECT @CompanyId = CompanyId, @HrsettingDetailId = HrsettingDetailId, @HrsettingId = HrsettingId   
  FROM @AllCompany_Tbl  
  WHERE S_No = @RecCount  
  
  INSERT INTO #Category_Tbl  
  SELECT DISTINCT CI.ID, CS.Id, CS.[Category], CS.[CategoryLimit],CSD.[AnnualLimit], CSD.[TransactionLimit],  CS.[ApplyTo], CS.[DepartmentId], CS.[DesignationId], CS.Type  
  FROM [HR].[ClaimSetup] CS (NOLOCK)  
  JOIN [HR].[ClaimItem] CI (NOLOCK) ON CS.[CompanyId] = CI.[CompanyId]  
  JOIN [HR].[ClaimSetupDetail] CSD (NOLOCK) ON CI.[Id] = CSD.[ClaimItemId]  
  WHERE CS.STATUS = 1 AND CI.STATUS = 1 and (CI.IsCategoryDisable is null or CI.IsCategoryDisable=0) AND CS.ID = CSD.[ClaimSetupId] AND CS.CompanyId = 1437 AND CI.CompanyId = 1437  
  
  SET @CategoryCount = (  
    SELECT Count(*)  
    FROM #Category_Tbl  
    )  
  
  DECLARE @RecCount1 INT = 1  
  
  --IF EXISTS @CategoryCount  
  --BEGIN --M2  
   WHILE @CategoryCount >= @RecCount1  
   BEGIN --2     
    DECLARE @ClaimSetUpId_New UNIQUEIDENTIFIER  
    DECLARE @ClaimItemId_New UNIQUEIDENTIFIER  
    DECLARE @CategoryName_New NVARCHAR(200)  
    DECLARE @CategoryLimit_New MONEY   
    DECLARE @TransactionLimit_New MONEY   
    DECLARE @AnnualLimit_New MONEY   
    DECLARE @Applyto_new NVARCHAR(200)  
    DECLARE @DepartmentId_New UNIQUEIDENTIFIER   
    DECLARE @DesignationId_New UNIQUEIDENTIFIER   
    DECLARE @Type_1New NVARCHAR(200)   
  
    SELECT @ClaimItemId_New = ClaimItemId, @ClaimSetUpId_New = ClaimSetuiId, @CategoryName_New = Category, @CategoryLimit_New = CategoryLimit, @AnnualLimit_New = AnnualLimit, @TransactionLimit_New = TransactionLimit, @Applyto_new = ApplyTo, @DepartmentId_New = [DepartmentId], @DesignationId_New = DesignationId, @Type_1New = Type_1  
    FROM #Category_Tbl  
    WHERE S_No = @RecCount1  
  
    IF (@Applyto_new = 'All')  
    BEGIN --m4  
      
    --print 'all'  
     INSERT INTO #AllEmployee_Tbl  
     SELECT  HE.ID, CE.Id,null,null  
     FROM Common.Employee CE (NOLOCK)  
     JOIN [HR].[EmployeeClaimsEntitlement] HE (NOLOCK) ON HE.[EmployeeId] = CE.Id  
     WHERE CE.CompanyId = 1437 AND CE.IdType IS NOT NULL AND CE.STATUS = 1 
  
     DECLARE @EmployeeCount INT = (  
       SELECT Count(*)  
       FROM #AllEmployee_Tbl  
       )  
     DECLARE @EmpRecCount INT = 1  
  
     --IF EXISTS @EmpRecCount  
     --BEGIN --M3  
      WHILE @EmployeeCount >= @EmpRecCount  
      BEGIN --3  
       DECLARE @EntitlementId_New UNIQUEIDENTIFIER   
       DECLARE @EmployeeId_New UNIQUEIDENTIFIER   
  
       SELECT @EntitlementId_New = EntitlementId, @EmployeeId_New = EmployeeID  
       FROM #AllEmployee_Tbl  
       WHERE S_No = @EmpRecCount  
        --print @RecCount1  
		 if not exists(select * from [Hr].[EmployeeClaimsEntitlementDetail] where EmployeeClaimsEntitlementId=@EntitlementId_New and ClaimItemId=@ClaimItemId_New and HrSettingDetaiId=@HrsettingDetailId and ClaimType=@Type_1New and Year = year(getdate()))
	  begin
	  PRINT 'Apply to all Insert the data'
       --INSERT [Hr].[EmployeeClaimsEntitlementDetail] ([Id], [EmployeeClaimsEntitlementId], [Year], [ClaimType], [ClaimItemId], [CategoryLimit], [TransactionLimit], [AnnualLimit], [UserCreated], [CreatedDate], [Status], [HrSettingDetaiId])  
       --VALUES (NewId(), @EntitlementId_New, year(getdate()), @Type_1New, @ClaimItemId_New, @CategoryLimit_New, @TransactionLimit_New, @AnnualLimit_New, 'system', GetDate(), 1, @HrsettingDetailId)  
        end
       SET @EmpRecCount = @EmpRecCount + 1  
      END --3  
     --END --M3  
       
    END --m4  
    truncate table #AllEmployee_Tbl  
    
	
	
	IF (@Applyto_new = 'Selected')  
    BEGIN --6  
    --print 'Selected'  
    --print @CompanyId  
     --DECLARE @AllDesignation_Tb TABLE (Designationid UNIQUEIDENTIFIER NULL)  
     IF ((@DepartmentId_New IS  NULL or @DepartmentId_New=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))) AND (@DesignationId_New IS NOT NULL and @DesignationId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))))  
  
     begin --m1  
     insert into #AllDesignation_Tb  
     SELECT DISTINCT dd.Id FROM [Common].[Department] d (NOLOCK) INNER JOIN [Common].[DepartmentDesignation] dd (NOLOCK)  
      ON d.id = dd.[DepartmentId] WHERE d.[CompanyId] = @CompanyId AND dd.code = (SELECT code FROM common.DepartmentDesignation (NOLOCK) WHERE Id = @DesignationId_New)  
     end--m1  
     IF ((@DepartmentId_New IS NOT NULL and @DepartmentId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))))  
     begin--mid  
     INSERT INTO #AllEmployee_Tbl  
     SELECT DISTINCT HE.ID, CE.Id, HED.[DepartmentId], HED.[DepartmentDesignationId]  
     FROM Common.Employee CE (NOLOCK)  
     JOIN [HR].[EmployeeClaimsEntitlement] HE (NOLOCK) ON HE.[EmployeeId] = CE.Id  
     JOIN [HR].[EmployeeDepartment] HED (NOLOCK) ON HED.EmployeeId = CE.Id  
     WHERE CE.CompanyId = @CompanyId AND CE.IdType IS NOT NULL AND CE.STATUS = 1 AND (Convert(DATE, HED.EffectiveFrom) <= Convert(DATE, GetDate()) AND (Convert(DATE, HED.EffectiveTo) >= Convert(DATE, GetDate()) OR HED.EffectiveTo IS NULL)) AND HED.DepartmentId = @DepartmentId_New AND CE.IdType IS NOT NULL AND CE.STATUS = 1  
    
	end --mid  
     else   
     begin--mid   
  
     INSERT INTO #AllEmployee_Tbl  
     SELECT DISTINCT HE.ID, CE.Id, HED.[DepartmentId], HED.[DepartmentDesignationId]  
     FROM Common.Employee CE (NOLOCK)  
     JOIN [HR].[EmployeeClaimsEntitlement] HE (NOLOCK) ON HE.[EmployeeId] = CE.Id  
     JOIN [HR].[EmployeeDepartment] HED (NOLOCK) ON HED.EmployeeId = CE.Id  
     WHERE CE.CompanyId = @CompanyId AND CE.IdType IS NOT NULL AND CE.STATUS = 1 AND (Convert(DATE, HED.EffectiveFrom) <= Convert(DATE, GetDate()) AND (Convert(DATE, HED.EffectiveTo) >= Convert(DATE, GetDate()) OR HED.EffectiveTo IS NULL)) AND HED.DepartmentDesignationId in (select Designationid from #AllDesignation_Tb )AND CE.IdType IS NOT NULL AND CE.STATUS = 1  
  
  
     end--mid  
  
  
  
  
  
     DECLARE @Count int  
     set @Count  = (  
       SELECT Count(*)  
       FROM #AllEmployee_Tbl  
       )  
     DECLARE @rec INT = 1  
     DECLARE @EntitlementId_New1 UNIQUEIDENTIFIER   
     DECLARE @EmployeeId_New1 UNIQUEIDENTIFIER   
     DECLARE @EmpDepartmentid_New UNIQUEIDENTIFIER   
     DECLARE @EmpDesignationId_New UNIQUEIDENTIFIER   
  
     WHILE @Count >= @rec  
     BEGIN --8  
     --if exists ( SELECT EmployeeID  
     -- FROM #AllEmployee_Tbl  
     -- WHERE S_No = @rec AND DepartmentId = @Departmentid_New)  
     -- begin --new  
      SELECT @EntitlementId_New1 = EntitlementId, @EmployeeId_New1 = EmployeeID, @EmpDepartmentid_New = DepartmentId, @EmpDesignationId_New = Designationid  
      FROM #AllEmployee_Tbl  
      WHERE S_No = @rec --AND DepartmentId = @Departmentid_New  
      --print @EntitlementId_New1  
      --print @EmployeeId_New1  
      --print '@EntitlementId_New1'+ '@EmployeeId_New1'+'ids checking'  
      --print @ClaimItemId_New  
      IF (@DepartmentId_New IS NOT NULL and @DepartmentId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER)) AND @DesignationId_New IS NOT NULL and @DesignationId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER)))  
      BEGIN --7  
       IF  (  
          @EmpDesignationId_New = @DesignationId_New and @EmpDepartmentid_New=@DepartmentId_New  
         )  
       BEGIN --10  
         
       --Print 'selected d and d is not null'  
       --print @Departmentid_New  
       --print @DesignationId_New  
       --print @EmployeeId_New1  
       --print @EntitlementId_New1 
	   if not exists(select * from [Hr].[EmployeeClaimsEntitlementDetail] where EmployeeClaimsEntitlementId=@EntitlementId_New and ClaimItemId=@ClaimItemId_New and HrSettingDetaiId=@HrsettingDetailId and ClaimType=@Type_1New and Year = year(getdate()))
	  begin
	     
		 Print '1'
        INSERT [Hr].[EmployeeClaimsEntitlementDetail] ([Id], [EmployeeClaimsEntitlementId], [Year], [ClaimType], [ClaimItemId], [CategoryLimit], [TransactionLimit], [AnnualLimit], [UserCreated], [CreatedDate], [Status], [HrSettingDetaiId])  
        VALUES (NewId(), @EntitlementId_New1, year(getdate()), @Type_1New, @ClaimItemId_New, @CategoryLimit_New, @TransactionLimit_New, @AnnualLimit_New, 'system', GetDate(), 1, @HrsettingDetailId)  
          end 
       END --10  
      END --7  
  
      else IF ((@DepartmentId_New IS NOT NULL and @DepartmentId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))) AND (@DesignationId_New IS NULL or @DesignationId_New=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))))  
      BEGIN --9  
      --print @EmployeeId_New1  
      --Print 'selected designation is null'  
      IF  (  
           @EmpDepartmentid_New=@DepartmentId_New  
         )  
         begin--mid  
		 if not exists(select * from [Hr].[EmployeeClaimsEntitlementDetail] where EmployeeClaimsEntitlementId=@EntitlementId_New and ClaimItemId=@ClaimItemId_New and HrSettingDetaiId=@HrsettingDetailId and ClaimType=@Type_1New and Year = year(getdate()))
	  begin
	   Print '2'
       INSERT [Hr].[EmployeeClaimsEntitlementDetail] ([Id], [EmployeeClaimsEntitlementId], [Year], [ClaimType], [ClaimItemId], [CategoryLimit], [TransactionLimit], [AnnualLimit], [UserCreated], [CreatedDate], [Status], [HrSettingDetaiId])  
       VALUES (NewId(), @EntitlementId_New1, year(getdate()), @Type_1New, @ClaimItemId_New, @CategoryLimit_New, @TransactionLimit_New, @AnnualLimit_New, 'system', GetDate(), 1, @HrsettingDetailId)  
       end--mid 
	   end
           
      END --9  
  
      else IF ((@DepartmentId_New IS  NULL or @DepartmentId_New=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))) AND (@DesignationId_New IS not NULL or @DesignationId_New!=(SELECT CAST(0x0 AS UNIQUEIDENTIFIER))))  
      begin --10  
      IF exists (  
          --@EmpDesignationId_New = @DesignationId_New  
          select Designationid from #AllDesignation_Tb where Designationid=@EmpDesignationId_New  
         )  
       BEGIN --11  
         
       --Print 'selected d and d is not null'  
       --print @Departmentid_New  
       --print @DesignationId_New  
       --print @EmployeeId_New1  
       --print @EntitlementId_New1  
	   if not exists(select * from [Hr].[EmployeeClaimsEntitlementDetail] where EmployeeClaimsEntitlementId=@EntitlementId_New and ClaimItemId=@ClaimItemId_New and HrSettingDetaiId=@HrsettingDetailId and ClaimType=@Type_1New and Year = year(getdate()))
	  begin
	  Print '3'
        INSERT [Hr].[EmployeeClaimsEntitlementDetail] ([Id], [EmployeeClaimsEntitlementId], [Year], [ClaimType], [ClaimItemId], [CategoryLimit], [TransactionLimit], [AnnualLimit], [UserCreated], [CreatedDate], [Status], [HrSettingDetaiId])  
        VALUES (NewId(), @EntitlementId_New1, year(getdate()), @Type_1New, @ClaimItemId_New, @CategoryLimit_New, @TransactionLimit_New, @AnnualLimit_New, 'system', GetDate(), 1, @HrsettingDetailId)  
         end  
       END --11  
      end --10  
  
  
      --end--new  
  
      SET @rec = @rec + 1  
     END --8  
    truncate table #AllEmployee_Tbl  
    truncate table #AllDesignation_Tb  
    END --6  
  
    SET @RecCount1 = @RecCount1 + 1  
   END --2  
  --END --M2  
  
  SET @RecCount = @RecCount + 1  
  truncate table #Category_Tbl  
 END --1  
--END --M1  
IF OBJECT_ID(N'tempdb..#AllEmployee_Tbl') IS NOT NULL  
BEGIN  
DROP TABLE #AllEmployee_Tbl  
END  
IF OBJECT_ID(N'tempdb..#Category_Tbl') IS NOT NULL  
BEGIN  
DROP TABLE #Category_Tbl  
END  
IF OBJECT_ID(N'tempdb..#AllDesignation_Tb') IS NOT NULL  
BEGIN  
DROP TABLE #AllDesignation_Tb  
END  
Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )  
values (newid(),'HRCursor','Claim Entitlement Insertion','Job','Claim Entitlement Insertion',@StartTime,getdate(),null,null,'Completed')  
Commit Transaction--s2  
 End try --s3  
 Begin Catch  
  ROLLBACK TRANSACTION  
  DECLARE  
    @ErrorMessage NVARCHAR(4000),  
    @ErrorSeverity INT,  
    @ErrorState INT;  
  SELECT  
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE();  
  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);  
  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )  
  values (newid(),'HRCursor','Claim Entitlement Insertion','Job','Claim Entitlement Insertion',@StartTime,getdate(),null,'Failed: '+ @ErrorMessage, 'Failed')  
 End Catch  
End  
  
GO

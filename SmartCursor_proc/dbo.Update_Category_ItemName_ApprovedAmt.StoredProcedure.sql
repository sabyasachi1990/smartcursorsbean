USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Update_Category_ItemName_ApprovedAmt]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Proc [dbo].[Update_Category_ItemName_ApprovedAmt]  -- exec  Update_Category_ItemName_ApprovedAmt 1
@CompanyId int
--,@employeeId uniqueidentifier

 as
 begin 
 declare @employeeId uniqueidentifier --= 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'

    Declare Update_Category_Csr Cursor For 
    select distinct e.Id  as EmployeeId from Common.Employee E
	inner join hr.EmployeeClaimsEntitlement ED ON ed.EmployeeId=E.ID
	where E.CompanyId=@CompanyId --and e.Id =@employeeId
    Open Update_Category_Csr
    Fetch Next From Update_Category_Csr into @employeeId
    While @@FETCH_STATUS=0
    BEGIN
---- ========================== ITEM LEVEL UTILIZED AMT UPDATION =============================
--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.ItemName, B.ItemName,A.EmployeeId,B.EmployeeId, A.item_UA, B.ApprovedAmt 
-------update A set A.item_UA = B.ApprovedAmt
--from
--(
--select ECED.ClaimItemId,B.ClaimItemId,ECE.EmployeeId ,B.EmployeeId,CI.Category,B.Category, CI.ItemName,B.ItemName, 
--(ECED.UtilizedAmount) as item_UA, B.ApprovedAmt
update ECED set ECED.UtilizedAmount = B.ApprovedAmt
from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId 
--and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails
--where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by ECED.ClaimItemId,CI.Category,CI.ItemName,ECE.EmployeeId 
--order by CI.Category, CI.ItemName
--) as A

Join
(
select ECD.ClaimItemId,EC.EmployeId AS EmployeeId, CI.Category, CI.ItemName, sum(ECD.ApprovedAmount) ApprovedAmt, EC.ClaimStatus
from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31' 
and EC.CaseGroupId is null and EC.ClaimStatus='Processed'
group by ECD.ClaimItemId,CI.Category,CI.ItemName, EC.ClaimStatus,EC.EmployeId 
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on ECED.ClaimItemId = B.ClaimItemId
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId 
and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails
where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by ECED.ClaimItemId,CI.Category,CI.ItemName,ECE.EmployeeId, B.ClaimItemId,B.EmployeeId,B.Category,B.ItemName,B.ApprovedAmt
--ORDER BY CI.Category, CI.ItemName




---- ========================== ITEM LEVEL PRE-PROCESSED AMT UPDATION =============================
--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.ItemName, B.ItemName, A.Item_PreProcessedAmt, B.ApprovedAmt 
--------update A set A.Item_PreProcessedAmt = B.ApprovedAmt
--from
--(
--select ECED.ClaimItemId,b.ClaimItemId, ECE.EmployeeId,b.EmployeId,CI.Category,b.Category, CI.ItemName,b.ItemName,
--(ECED.SubmittedAmount) as Item_PreProcessedAmt,ApprovedAmt 
update ECED set ECED.SubmittedAmount = B.ApprovedAmt
from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--) as A
--order by CI.Category, CI.ItemName
Join
(
select ECD.ClaimItemId, EC.EmployeId,CI.Category, CI.ItemName, sum(ECD.ApprovedAmount) ApprovedAmt from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31'
and EC.CaseGroupId is null and (EC.ClaimStatus='Submitted' OR EC.ClaimStatus = 'Verified' OR EC.ClaimStatus = 'Reviewed' OR EC.ClaimStatus = 'Approved')
group by ECD.ClaimItemId,CI.Category,CI.ItemName,EC.EmployeId 
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on ECED.ClaimItemId = B.ClaimItemId
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId 
and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails
where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by ECED.ClaimItemId,CI.Category,CI.ItemName 
--ORDER BY CI.Category,CI.ItemName 


---- ========================== ITEM LEVEL BAL AMT UPDATION =============================
--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select CI.Category,CI.ItemName,ECE.EmployeeId,ECED.RemainingAmount,
-------update ECED set ECED.RemainingAmount = 
--(Case when (ECED.AnnualLimit) is null and (ECED.TransactionLimit) is not null then ((Isnull(ECED.TransactionLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0))))
--          when (ECED.AnnualLimit) is not null and (ECED.TransactionLimit) is null then ((Isnull(ECED.AnnualLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0))))
--          when (ECED.AnnualLimit) is null and (ECED.TransactionLimit) is null then null
--          when (ECED.AnnualLimit) is not null and (ECED.TransactionLimit) is not null then ((Isnull(ECED.AnnualLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0)))) end) 

update ECED set ECED.RemainingAmount = (Case when (ECED.AnnualLimit) is null and (ECED.TransactionLimit) is not null then ((Isnull(ECED.TransactionLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0))))
          when (ECED.AnnualLimit) is not null and (ECED.TransactionLimit) is null then ((Isnull(ECED.AnnualLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0))))
          when (ECED.AnnualLimit) is null and (ECED.TransactionLimit) is null then null
          when (ECED.AnnualLimit) is not null and (ECED.TransactionLimit) is not null then ((Isnull(ECED.AnnualLimit,0)) - ((Isnull(ECED.UtilizedAmount,0)) + (Isnull(ECED.SubmittedAmount,0)))) end) 
from hr.EmployeeClaimsEntitlement ECE
Join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
---group by CI.ItemName,ECED.AnnualLimit, ECED.TransactionLimit, ECED.UtilizedAmount, ECED.SubmittedAmount,ECED.RemainingAmount
--order by CI.Category,CI.ItemName

--===========================================================================================================
--===============================================================================================================


---- ========================== CATEGORY LEVEL UTILIZED AMT UPDATION =============================
---declare @employeeId uniqueidentifier ='CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.item_UA, B.ApprovedAmt 
----update A set A.item_UA = B.ApprovedAmt
--from
--(
 --select ECED  .Id,ECED.CategoryUtilizedAmount,gg.ApprovedAmt,rank 
 update ECED set ECED.CategoryUtilizedAmount = gg.ApprovedAmt
 from  hr.EmployeeClaimsEntitlementDetail ECED  
 inner join
(
select b.Category,ECED.Id, (ECED.CategoryUtilizedAmount) as cat_UA ,b.ApprovedAmt
,rank() over(partition by CI.Category order by ECED.id desc) as rank 
--update ECED set ECED.CategoryUtilizedAmount= B.ApprovedAmt
 from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by CI.Category
--) as A
--order by CI.Category, CI.ItemName
Join
(
select CI.Category, sum(ECD.ApprovedAmount) ApprovedAmt from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31' and EC.CaseGroupId is null and (EC.ClaimStatus='Processed')
group by CI.Category 
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on CI.Category = B.Category
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId 
and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails 
where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
)gg on gg.Id=ECED.id
 where rank=1


 ---declare @employeeId uniqueidentifier ='CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.item_UA, B.ApprovedAmt 
----update A set A.item_UA = B.ApprovedAmt
--from
--(
 --select ECED  .Id,ECED.CategoryUtilizedAmount,gg.ApprovedAmt,rank 
 update ECED set ECED.CategoryUtilizedAmount = null
 from  hr.EmployeeClaimsEntitlementDetail ECED  
 inner join
(
select b.Category,ECED.Id, (ECED.CategoryUtilizedAmount) as cat_UA ,b.ApprovedAmt
,rank() over(partition by CI.Category order by ECED.id desc) as rank 
--update ECED set ECED.CategoryUtilizedAmount= B.ApprovedAmt
 from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by CI.Category
--) as A
--order by CI.Category, CI.ItemName
Join
(
select CI.Category, sum(ECD.ApprovedAmount) ApprovedAmt from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31' and EC.CaseGroupId is null and (EC.ClaimStatus='Processed')
group by CI.Category 
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on CI.Category = B.Category
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId 
and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails 
where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
)gg on gg.Id=ECED.id
 where rank<>1

---- ========================== CATEGORY LEVEL PRE-PROCESSED AMT UPDATION =============================

--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.Item_PreProcessedAmt, B.ApprovedAmt 
----update A set A.Item_PreProcessedAmt = B.ApprovedAmt
--from
--(
 --select ECED  .Id,ECED.CategoryPreApprovedAmount,gg.ApprovedAmt,rank 
 update ECED set ECED.CategoryPreApprovedAmount = gg.ApprovedAmt
 from  hr.EmployeeClaimsEntitlementDetail ECED  
 inner join
(
select  ECED.Id,CI.Category,
(ECED.CategoryPreApprovedAmount) as cat_PreProcessedAmt,B.ApprovedAmt 
,rank() over(partition by CI.Category order by ECED.id desc) as rank 
--update ECED set ECED.CategoryPreApprovedAmount = B.ApprovedAmt
from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by ECED.ClaimItemId,CI.Category,CI.ItemName 
--) as A
--order by CI.Category, CI.ItemName
Join
(
select  CI.Category, sum(ECD.ApprovedAmount) ApprovedAmt from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31' and EC.CaseGroupId is null and (EC.ClaimStatus='Submitted' OR EC.ClaimStatus = 'Verified' OR EC.ClaimStatus = 'Reviewed' OR EC.ClaimStatus = 'Approved')
group by CI.Category
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on  CI.Category = B.Category
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
)gg on gg.Id=ECED.id
 where rank=1
--group by ECED.ClaimItemId,CI.Category,CI.ItemName 


--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select A.Category, B.Category, A.Item_PreProcessedAmt, B.ApprovedAmt 
----update A set A.Item_PreProcessedAmt = B.ApprovedAmt
--from
--(
 --select ECED  .Id,ECED.CategoryPreApprovedAmount,gg.ApprovedAmt,rank 
 update ECED set ECED.CategoryPreApprovedAmount =null
 from  hr.EmployeeClaimsEntitlementDetail ECED  
 inner join
(
select  ECED.Id,CI.Category,
(ECED.CategoryPreApprovedAmount) as cat_PreProcessedAmt,B.ApprovedAmt 
,rank() over(partition by CI.Category order by ECED.id desc) as rank 
--update ECED set ECED.CategoryPreApprovedAmount = B.ApprovedAmt
from hr.EmployeeClaimsEntitlement ECE
join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
--where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by ECED.ClaimItemId,CI.Category,CI.ItemName 
--) as A
--order by CI.Category, CI.ItemName
Join
(
select  CI.Category, sum(ECD.ApprovedAmount) ApprovedAmt from hr.EmployeeClaim1 EC
join hr.EmployeeClaimDetail ECD  on EC.Id  =ECD.EmployeeClaimId
Join hr.ClaimItem CI on CI.Id = ECD.ClaimItemId
Where EC.ParentCompanyId=1 and EC.EmployeId=@employeeId and EC.MasterClaimDate between '2020-01-01' and '2020-12-31' and EC.CaseGroupId is null and (EC.ClaimStatus='Submitted' OR EC.ClaimStatus = 'Verified' OR EC.ClaimStatus = 'Reviewed' OR EC.ClaimStatus = 'Approved')
group by CI.Category
--order by CI.Category, CI.ItemName, EC.ClaimStatus
) as B on  CI.Category = B.Category
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
)gg on gg.Id=ECED.id
 where rank<>1
--group by ECED.ClaimItemId,CI.Category,CI.ItemName 
---- ========================== CATEGORY LEVEL BAL AMT UPDATION =============================
--declare @employeeId uniqueidentifier = 'CC51AC0E-6226-4965-A22F-40FFC6F43D43'
--select CI.Category,ECED.CategoryBalanceAmount,
----update ECED set ECED.CategoryBalanceAmount = 
--(Case when (ECED.CategoryLimit) is null then null  else
--              (Isnull(ECED.CategoryLimit,0)) - ((Isnull(ECED.CategoryUtilizedAmount,0)) + (Isnull(ECED.CategoryPreApprovedAmount,0))) end)

update ECED set ECED.CategoryBalanceAmount = 
(Case when (ECED.CategoryLimit) is null then null  else
              (Isnull(ECED.CategoryLimit,0)) - ((Isnull(ECED.CategoryUtilizedAmount,0)) + (Isnull(ECED.CategoryPreApprovedAmount,0))) end)

from hr.EmployeeClaimsEntitlement ECE
Join hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
join hr.ClaimItem CI on CI.Id = ECED.ClaimItemId
where ECED.Status=1 and ECE.Status=1 and ECE.EmployeeId=@employeeId and ECED.HrSettingDetaiId=(select Id from Common.HRSettingdetails where MasterId=(select Id from Common.HRSettings where CompanyId=1) and Convert(date,StartDate)=Convert(date,'2020-01-01'))
--group by CI.Category,ECED.CategoryLimit,ECED.CategoryUtilizedAmount,ECED.CategoryPreApprovedAmount,ECED.CategoryBalanceAmount
   
   Fetch Next From Update_Category_Csr  into @employeeId
   END
   Close Update_Category_Csr
   Deallocate Update_Category_Csr
end
GO

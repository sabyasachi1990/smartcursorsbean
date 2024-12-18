USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[MigrationSubscription]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[MigrationSubscription]  --- exec [dbo].[MigrationSubscription]  
as
begin 
Declare @temp table (CompanyId bigint ,listStr nvarchar(max))
Declare @temp1 table (Taxid bigint ,Taxcode nvarchar(4000))
Declare @Subscription table (
Id uniqueidentifier ,CompanyId bigint,PartnerId bigint,ProgramId uniqueidentifier, SubscriptionName nvarchar(4000),BillingFrequency nvarchar(4000),NextBillingDate datetime2,Price  money,
PartnerPrice money, LicensesReserved int,LicensesUsed int,LicensesReduced int,Status int,
UserCreated nvarchar(4000),CreatedDate datetime2,PackageId uniqueidentifier,PayTerm nvarchar(4000),Emails nvarchar(MAX), CurrencyCode nvarchar(4000),
TotalAmount money,TaxCode nvarchar(4000),TaxId bigint,TaxRate bigint,EffectiveTo datetime2,EffectiveFrom datetime2,SubscriptionDetailid uniqueidentifier,TaxPrice money,Quantity  int
)
DELETE FROM dbo.[Licenses_Migrations] WHERE  CompanyId IS  NULL AND SubscriptionName IS NULL  
 
insert into @temp
select CompanyId, listStr from 
(
 SELECT  CompanyId,STUFF((SELECT  ',' + Email from 
(
    select Email,CompanyId from Common.CompanyUser WHERE IsAdmin=1 AND Email IS NOT NULL 
    AND CompanyId=e.CompanyId 
 )ee
   FOR XML PATH('')), 1, 1, '') AS listStr
FROM Common.CompanyUser E WHERE IsAdmin=1 AND Email IS NOT NULL 
)gg
GROUP BY CompanyId, listStr
 
  insert into @temp1
  select distinct t.id as Taxid ,Taxcode from  dbo.[Licenses_Migrations] A
  inner join  Bean.TaxCode t on t.Code=a.Taxcode
  where taxcode is not null and t.CompanyId=0
 
     Begin Transaction  
     Begin Try 
     --===========================================================
          
          INSERT INTO @Subscription
          (
          Id ,CompanyId,PartnerId,ProgramId, SubscriptionName,BillingFrequency,NextBillingDate,Price ,PartnerPrice, 
          LicensesReserved,LicensesUsed,LicensesReduced,Status, UserCreated,CreatedDate,PackageId,PayTerm,
          Emails, CurrencyCode,TotalAmount,TaxCode,TaxId,TaxRate,EffectiveTo,EffectiveFrom ,SubscriptionDetailid,TaxPrice,Quantity 
          )
         SELECT Newid() as Id ,a.CompanyId, case when a.PartnerId=''  then null else a.PartnerId end PartnerId,p.ProgramId,concat('Scm_','',a.SubscriptionName) as SubscriptionName,A.BillingFrequency,CONVERT(datetime2,NextBillingDate,103) as NextBillingDate ,
         cast ( A.Price as Money) as  Price, cast ( A.PartnerPrice as Money) as  PartnerPrice, 
         Case when p.QuantityValues is not null and a.LicensesReserved is not null  then 
          case  
          when   cast ( a.LicensesReserved as int ) <=15 then 15 
          when   cast ( a.LicensesReserved as int ) between 15 and 20 then 20 
          when   cast ( a.LicensesReserved as int ) between 20 and 25 then 25
          when   cast ( a.LicensesReserved as int ) between 25 and 30 then 30
          when   cast ( a.LicensesReserved as int ) between 30 and 35 then 35 
          when   cast ( a.LicensesReserved as int ) between 35 and 40 then 40
          when   cast ( a.LicensesReserved as int ) between 40 and 45 then 45
          when   cast ( a.LicensesReserved as int ) between 45 and 50 then 50 end  else  cast ( a.LicensesReserved as int ) end   AS LicensesReserved,
           cast ( a.LicensesUsed as int ) LicensesUsed, cast ( a.LicensesReduced as int ) LicensesReduced,A.Status,'System' as UserCreated,CONVERT(datetime2,GETUTCDATE(),103) as  CreatedDate,P.id as PackageId,A.PayTerm,
          T.listStr AS  Emails,'SGD' AS CurrencyCode,cast ( A.TotalAmount as Money) as TotalAmount,A.TaxCode,T1.Taxid AS  TaxId,case when TaxRate=''  then null else TaxRate end TaxRate,CONVERT(datetime2,a.EffectiveTo,103) EffectiveTo, CONVERT(datetime2,a.EffectiveFrom,103)  EffectiveFrom ,
          Newid() as SubscriptionDetailid ,case when a.TaxRate is not null and A.Price is not null then (cast(a.TaxRate as int) * cast ( isnull(A.Price,0) as Money))/100  else cast (A.Price as Money) end  as TaxPrice,cast(a.Quantity as int) AS Quantity
          FROM dbo.[Licenses_Migrations] A
          INNER JOIN License.Package P ON P.[Name]=A.SubscriptionName 
          LEFT JOIN @temp T ON T.CompanyId=A.CompanyId
          LEFT JOIN @temp1 T1 ON T1.Taxcode=A.TaxCode
          LEFT JOIN 
          (
          SELECT CompanyId AS ID ,SubscriptionName AS SNAME,PackageId AS SPackageId,ProgramId AS SProgramId  FROM License.Subscription 
          )GG ON GG.ID=A.CompanyId AND GG.SNAME=concat('Scm_','',a.SubscriptionName) AND GG.SPackageId=P.Id AND GG.SProgramId=P.ProgramId
          where p.Country='Singapore' AND A.CompanyId IS NOT NULL AND A.SubscriptionName IS NOT NULL  AND GG.SNAME IS NULL 
          order by SubscriptionName

        INSERT INTO License.Subscription 
        (
         Id ,CompanyId,PartnerId,ProgramId, SubscriptionName,BillingFrequency,NextBillingDate,Price ,PartnerPrice, 
         LicensesReserved,LicensesUsed,LicensesReduced,Status, UserCreated,CreatedDate,PackageId,PayTerm,
         Emails, CurrencyCode,TotalAmount,TaxCode,TaxId,TaxRate,EffectiveTo,EffectiveFrom 
         )
 
         SELECT  distinct Id ,CompanyId,PartnerId,ProgramId, SubscriptionName,BillingFrequency,NextBillingDate,Price ,PartnerPrice, 
         LicensesReserved,LicensesUsed,LicensesReduced,Status, UserCreated,CreatedDate,PackageId,PayTerm,
         Emails, CurrencyCode,case when Quantity IS NOT NULL then cast(Quantity as int)*cast ( Price as Money)  else cast ( Price as Money) end  TotalAmount,TaxCode,TaxId,TaxRate,EffectiveTo, EffectiveFrom FROM @Subscription
         where TaxId is not null 
 

         INSERT INTO License.SubscriptionDetailHistory 
        (
         ID,SubscriptionId ,Quantity,Price,PartnerPrice,ValidityPeriodFrom,ValidityPeriodTo,Status,UserCreated,CreatedDate 
         )
         SELECT SubscriptionDetailid AS ID ,ID AS SubscriptionId ,Quantity,CASE WHEN Quantity IS NOT NULL THEN ISNULL(Quantity,0)*ISNULL(Price,0) ELSE Price END  AS Price, CASE WHEN Quantity IS NOT NULL THEN ISNULL(Quantity,0)*ISNULL(PartnerPrice,0) ELSE PartnerPrice END  AS PartnerPrice,
         EffectiveFrom AS ValidityPeriodFrom,EffectiveTo AS ValidityPeriodTo,Status, UserCreated,CreatedDate 
         FROM @Subscription  where TaxId is not null 
 
  
 
         declare @companyId bigint
         declare CompanyUserSubscription_Cursor cursor for (select distinct companyId from @Subscription)
         open CompanyUserSubscription_Cursor
         fetch next from CompanyUserSubscription_Cursor into @companyId
         while @@FETCH_STATUS = 0
         BEGIN
            print @companyId
 
            update R set R.SubscriptionId = s.Id
            from Auth.RoleNew R
            left join License.PackageModule PM on PM.ModuleMasterId = R.ModuleMasterId
            left join License.Subscription S on S.PackageId = PM.PackageId
            where R.CompanyId=@companyId and s.CompanyId=@companyId
 
            insert into Common.CompanyUserSubscription (Id, CompanyId, CompanyUserId, SubscriptionId,UserCreated, CreatedDate, ModifiedBy, ModifiedDate)
            select NEWID(), R.CompanyId, URN.CompanyUserId, R.SubscriptionId, 'System', GETUTCDATE(), NULL, NULL from Auth.UserRoleNew URN
            join auth.roleNew R on URN.roleId = R.Id
            where r.CompanyId=@companyId and R.SubscriptionId is not null and companyId not in (select distinct companyId from Common.CompanyUserSubscription)
            group by CompanyUserId, SubscriptionId, R.CompanyId
 

            insert into License.CompanyPackageModule (Id, CompanyId, SubscriptionId, ModuleMasterId, LicensesReserved, LicensesUsed, ChargeUnit)
            select NEWID(),B.CompanyId, null, A.ModuleMasterId, A.LicensesReserved, B.LicensesUsed, A.ChargeUnit  from(
            (
                select S.CompanyId, pM.ModuleMasterId, s.LicensesReserved,P.ChargeUnit 
                from License.Subscription S
                join License.Package P on s.PackageId = p.Id
                join License.PackageModule PM on PM.PackageId = P.Id
                where s.CompanyId =@companyId  and s.Status=1
                group by  S.CompanyId,PM.ModuleMasterId,s.LicensesReserved,P.ChargeUnit
                ) A
                join(
                select R.companyId, MM.Id as ModuleId, ISNULL(COUNT( distinct CompanyUserId),0) as LicensesUsed
                from Auth.UserRoleNew URN
                inner join Common.CompanyUser CU on CU.Id=URN.CompanyUserId
                inner join Auth.RoleNew R on R.Id = URN.RoleId
                inner join Common.ModuleMaster MM on R.ModuleMasterId = MM.Id
                inner join Common.Company C on R.CompanyId = C.Id
                where c.Id =@companyId and CU.Status=1 and URN.Status=1 and R.Status=1 and c.ParentId IS NULL and MM.IsModuleShow = 1 
                group by R.companyId, MM.Id
                ) B on A.ModuleMasterId = B.ModuleId and A.CompanyId = B.CompanyId
            )
            where B.CompanyId not in (select distinct companyId from License.CompanyPackageModule)
 
            fetch next from CompanyUserSubscription_Cursor into @companyId
 
         END
         close CompanyUserSubscription_Cursor
         deallocate CompanyUserSubscription_Cursor
 
          --insert into Common.CompanyUserSubscription (Id, CompanyId, CompanyUserId, SubscriptionId,UserCreated, CreatedDate, ModifiedBy, ModifiedDate)
    --      select NEWID(), R.CompanyId, URN.CompanyUserId, R.SubscriptionId, 'System', GETUTCDATE(), NULL, NULL from Auth.UserRoleNew URN
    --      join auth.roleNew R on URN.roleId = R.Id
          --left join Common.CompanyUserSubscription c on c.CompanyUserId=URN.CompanyUserId and c.SubscriptionId=R.SubscriptionId and c.CompanyId=r.CompanyId
    --      where  R.SubscriptionId is not null and c.id is null and R.CompanyId in (select distinct CompanyId from @Subscription) 
    --      group by URN.CompanyUserId, R.SubscriptionId, R.CompanyId
 
  --      update R set R.SubscriptionId = s.Id
  --      from Auth.RoleNew R
  --      left join License.PackageModule PM on PM.ModuleMasterId = R.ModuleMasterId
  --      left join License.Subscription S on S.PackageId = PM.PackageId
  --      where R.CompanyId in (select distinct CompanyId from @Subscription) 
        --and s.CompanyId in (select distinct CompanyId from @Subscription)
 
        --insert into License.CompanyPackageModule (Id, CompanyId, SubscriptionId, ModuleMasterId, LicensesReserved, LicensesUsed, ChargeUnit)
        --select NEWID(),B.CompanyId, null, A.ModuleMasterId, A.LicensesReserved, B.LicensesUsed, A.ChargeUnit  from(
        --(
        --    select S.CompanyId, pM.ModuleMasterId, s.LicensesReserved,P.ChargeUnit 
        --    from License.Subscription S
        --    join License.Package P on s.PackageId = p.Id
        --    join License.PackageModule PM on PM.PackageId = P.Id
        --    where s.CompanyId in (select distinct CompanyId from @Subscription)  and s.Status=1
        --    group by  S.CompanyId,PM.ModuleMasterId,s.LicensesReserved,P.ChargeUnit
        --    ) A
        --    join(
        --    select R.companyId, MM.Id as ModuleId, ISNULL(COUNT( distinct CompanyUserId),0) as LicensesUsed
        --    from Auth.UserRoleNew URN
        --    inner join Common.CompanyUser CU on CU.Id=URN.CompanyUserId
        --    inner join Auth.RoleNew R on R.Id = URN.RoleId
        --    inner join Common.ModuleMaster MM on R.ModuleMasterId = MM.Id
        --    inner join Common.Company C on R.CompanyId = C.Id
        --    where c.Id in (select distinct CompanyId from @Subscription) and CU.Status=1 and URN.Status=1 and R.Status=1 and c.ParentId IS NULL and MM.IsModuleShow = 1 
        --    group by R.companyId, MM.Id
        --    ) B on A.ModuleMasterId = B.ModuleId and A.CompanyId = B.CompanyId
        --)
 
 
 --===========================================================
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
    Declare @ErrorMessage Nvarchar(4000)=error_message();
    ROLLBACK; 
      If @ErrorMessage is not null
      begin 
      select @ErrorMessage
      End 
    END CATCH
End 
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [License].[Validate_Subscription]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create
 procedure [License].[Validate_Subscription](@packageIds nvarchar(max), @jurisdiction nvarchar(100), @companyId Bigint=null)
 as 
 Begin
BEGIN TRY
--Exec [License].[Validate_Subscription] 'a272eb39-5eae-4661-ac09-1c0ef91dcb9e,A0F3CAA7-C7AC-43AF-8801-F096768DBA90' , 'Singapore'
--Declare @packageIds nvarchar(max) ='BF6B394D-1BF6-4EF0-B054-A1FEA3B81DA4,BF6B394D-1BF6-4EF0-B054-A1FEA3B81DA4'
--Declare @jurisdiction nvarchar(100) = 'Singapore'
--Declare @companyId Bigint = 3075
Declare @LicenseTBL table (S_no Int Identity(1,1),ID uniqueidentifier)
Declare @PMSActive table (ID uniqueidentifier)
INSERT INTO @LicenseTBL
select cast (LTRIM(RTRIM(items))  as uniqueidentifier)  from dbo.SplitToTable(@packageIds,',')
--SELECT *,@jurisdiction AS Country FROM  @LicenseTBL

    Declare @Count Int
	Declare @PMSCount Int
    Declare @RecCount Int
    Declare @ID uniqueidentifier
	Declare @Valiadate int
	set @Valiadate=1
        Set @Count=(Select Count(*) From @LicenseTBL)
        Set @RecCount=1
        While @Count>=@RecCount and @Valiadate<>0
        Begin
            Set @ID=(Select ID From @LicenseTBL Where S_no=@RecCount)
            DECLARE @ExcludePackageIds nvarchar(max)=(select  ExcludePackageIds from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)

			if (@ExcludePackageIds is not null)
			Begin

			 Declare @packageName nvarchar(max) = (select  Name from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)
			 Declare @SecondPackagename nvarchar(max) = (select  Name from License.Package  where Id in (SELECT  ID  FROM  @LicenseTBL where
              id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds,',')))AND Country=@jurisdiction)
			  if(@companyId is not null)
			  Begin
			   Declare @PMSPAckCount int =  (select Count(*) from License.Subscription where CompanyId=@companyId and SubscriptionName like '%Practice Management%' and Status=1)
			   if(@PMSPAckCount>0)
			   Begin
			 insert into @PMSActive(ID) (select  Id from License.Subscription  where PackageId in (SELECT ID  FROM  @LicenseTBL where
               id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds,','))) AND CompanyId=@companyId and SubscriptionName like '%Practice Management%' and Status = 1)

			   	 --Declare @PMSInActive nvarchar(max) = (select  SubscriptionName from License.Subscription  where PackageId in (SELECT ID  FROM  @LicenseTBL where
        --       id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds,','))) AND CompanyId=@companyId and SubscriptionName like '%Practice Management%' and Status = 4)
			 Set @PMSCount=(Select Count(*) From @PMSActive)
            if(@PMSCount>0)
			Begin
			--if(@PMSInActive is null)
			   --Begin
			 declare @exception nvarchar(500) = concat('You can not have both packages together ' ,  @packageName , ' and ' , @SecondPackagename)
			 raiserror(@exception,16,1)
			 --end
			 end
			 set @Valiadate=1
             End 
			 Else
			 Begin
			 Set @ID=(Select ID From @LicenseTBL Where S_no=@RecCount)
            DECLARE @ExcludePackageIds4 nvarchar(max)=(select  ExcludePackageIds from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)
			if (@ExcludePackageIds4 is not null)
			Begin
            IF  EXISTS ( SELECT ID  FROM  @LicenseTBL where
             Id NOT IN (@ID) and id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds4,',')))
			  BEGIN
			 Declare @packageName4 nvarchar(max) = (select  Name from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)
			 Declare @SecondPackagename4 nvarchar(max) = (select  Name from License.Package  where Id in (SELECT top 1 ID  FROM  @LicenseTBL where
             Id NOT IN (@ID) and id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds4,',')))AND Country=@jurisdiction)
            
			 declare @exception4 nvarchar(500) = concat('You can not have both packages together ' ,  @packageName4 , ' and ' , @SecondPackagename4)
			 raiserror(@exception4,16,1)
             --PRINT 'You can not have both packages together '+ @packageName + ' and ' + @SecondPackagename
			 set @Valiadate=1
             END 
			 end
            Set @RecCount=@RecCount+1
			 end
			 End
			 
			 else
			 begin
			 Set @ID=(Select ID From @LicenseTBL Where S_no=@RecCount)
            DECLARE @ExcludePackageIds2 nvarchar(max)=(select  ExcludePackageIds from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)
			if (@ExcludePackageIds2 is not null)
			Begin
            IF  EXISTS ( SELECT ID  FROM  @LicenseTBL where
             Id NOT IN (@ID) and id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds2,',')))
			  BEGIN
			 Declare @packageName2 nvarchar(max) = (select  Name from License.Package  where ExcludePackageIds is not null and Id=@ID AND Country=@jurisdiction)
			 Declare @SecondPackagename2 nvarchar(max) = (select  Name from License.Package  where Id in (SELECT top 1 ID  FROM  @LicenseTBL where
             Id NOT IN (@ID) and id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS ExcludePackageIds  from dbo.SplitToTable(@ExcludePackageIds2,',')))AND Country=@jurisdiction)
            
			 declare @exception2 nvarchar(500) = concat('You can not have both packages together ' ,  @packageName2 , ' and ' , @SecondPackagename2)
			 raiserror(@exception2,16,1)
             --PRINT 'You can not have both packages together '+ @packageName + ' and ' + @SecondPackagename
			 set @Valiadate=1
             END 
			 end
            Set @RecCount=@RecCount+1
			 end
			 End
			 --end
            Set @RecCount=@RecCount+1
        End


		
		Begin
Declare @LicenseTBL1 table (S_no1 Int Identity(1,1),ID uniqueidentifier)
Declare @Valiadate1 int
	set @Valiadate1=1
INSERT INTO @LicenseTBL1
select cast (LTRIM(RTRIM(items))  as uniqueidentifier)  from dbo.SplitToTable(@packageIds,',')
--SELECT *,@jurisdiction AS Country FROM  @LicenseTBL
    Declare @Count1 Int
    Declare @RecCount1 Int
    Declare @ID1 uniqueidentifier
	
        Set @Count1=(Select Count(*) From @LicenseTBL1)
		select * from @LicenseTBL1
        Set @RecCount1=1
        While (@Count1>=@RecCount1 and @Valiadate1<>0)
        Begin
		
			
			Set @ID1=(Select ID From @LicenseTBL1 Where S_no1=@RecCount1)
            DECLARE @DependantPackageIds1 nvarchar(max)=(select  DependantPackageIds from License.Package  where DependantPackageIds is not null and  Id=@ID1 AND Country=@jurisdiction)

			if (@DependantPackageIds1 is not null)
			begin
			select @DependantPackageIds1

             IF not EXISTS ( select DISTINCT Id from @LicenseTBL1  where Id  in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)   AS DependantPackageIds  from dbo.SplitToTable(@DependantPackageIds1,',')))
			 Begin
			  Declare @packageName3 nvarchar(max) = (select  Name from License.Package  where Id=@ID1 AND Country=@jurisdiction)
			 Declare @SecondPackagename3 nvarchar(max) = (select  Name from License.Package where id in (select @DependantPackageIds1))
             BEGIN
			  begin
			 declare @exception3 nvarchar(500) = concat(@SecondPackagename3 , ' package is required to choose ' ,  @packageName3 )
			end
			 raiserror(@exception3,16,1)
			 set @Valiadate1=1
             END
			 end
			 end
			 
            Set @RecCount1=@RecCount1+1
        End
		END




--		Begin
--Declare @LicenseTBL2 table (S_no2 Int Identity(1,1),ID uniqueidentifier)
--Declare @Valiadate2 int
--	set @Valiadate2=1
--INSERT INTO @LicenseTBL2
--select cast (LTRIM(RTRIM(items))  as uniqueidentifier)  from dbo.SplitToTable(@packageIds,',')
----SELECT *,@jurisdiction AS Country FROM  @LicenseTBL
--    Declare @Count2 Int
--    Declare @RecCount2 Int
--    Declare @ID2 uniqueidentifier
	
--        Set @Count2=(Select Count(*) From @LicenseTBL2)
--        Set @RecCount2=1
--        While (@Count2>=@RecCount2 and @Valiadate2<>0)
--        Begin
--		if(@companyId is not null)
--		begin
--            Set @ID2=(Select ID From @LicenseTBL2 Where S_no2=@RecCount2)
--            DECLARE @PackName nvarchar(max)=(select  SubscriptionName from License.Subscription  where CompanyId=@companyId and   PackageId=@ID2 and Status=1)
	
--			if (@PackName like '%Accounting with Multi Entity%')
--			Begin
--			Declare @MultiEntityId uniqueidentifier = (select Id from License.Package where Name like '%Accounting with Multi Entity%' and Country=@jurisdiction)
--			IF  EXISTS ( SELECT ID  FROM  @LicenseTBL2 where ID  in(@ID2) and
--             @MultiEntityId in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)  from dbo.SplitToTable(@packageIds,',')))
--			BEGIN
--			  begin
--			 declare @exception5 nvarchar(500) = concat(@PackName , ' package with the frequency should be unique. Please verify.' )
--			end
--			 raiserror(@exception5,16,1)
			 
--			 set @Valiadate2=1
--             END
--			 		END
--					Else if (@PackName like '%Accounting with Single Entity%')
--					Begin
--					Begin
--			Declare @SingleEntityId uniqueidentifier = (select Id from License.Package where Name like '%Accounting with Single Entity%' and Country=@jurisdiction)
--			IF  EXISTS ( SELECT ID  FROM  @LicenseTBL2 where
--             @SingleEntityId in (select cast (LTRIM(RTRIM(items))  as uniqueidentifier)  from dbo.SplitToTable(@packageIds,',')))
--			BEGIN
--			  begin
--			 declare @exception6 nvarchar(500) = concat(@PackName , ' package with the frequency should be unique. Please verify.' )
--			end
--			 raiserror(@exception6,16,1)
			 
--			 set @Valiadate2=1
--             END
--			 		END
--					End
--		END
--            Set @RecCount2=@RecCount2+1
--        End
--		END



		END TRY
 BEGIN CATCH
    --PRINT 'FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	--ROLLBACK;
END CATCH
		End
GO

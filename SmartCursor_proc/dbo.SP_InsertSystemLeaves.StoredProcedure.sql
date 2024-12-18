USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertSystemLeaves]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[SP_InsertSystemLeaves]  --Eexc SP_InsertSystemLeaves '2F2574CE-C8BB-4B8D-82C3-32EB32CBE4E8' ,1
@EmployeeId uniqueidentifier,
@CompanyId bigint
AS
Begin

	Declare @CurrentYear Nvarchar(30) =Year(Getdate())
	Declare @Getdate DateTime2=Getdate()
	Declare @HRSettingsStartDate  DateTime2
	Declare @HRSettingsEndDate  DateTime2
	Declare @HRSettingdetailsId uniqueidentifier
	Declare @ChildcareDays6 int
	Declare @ChildcareDays2 int
	Declare @MaternityDays int
	Declare @PaternityDays int
	Declare @UnpaidinfantcareDays int
	Declare @ChildcareLeaveTypeId uniqueidentifier
	Declare @MaternityLeaveTypeId uniqueidentifier
	Declare @PaternityLeaveTypeId uniqueidentifier
	Declare @UnpaidinfantcareLeaveTypeId uniqueidentifier
	Declare @ChildcareRecOrder int
	Declare @MaternityRecOrder int
	Declare @PaternityRecOrder int
	Declare @UnpaidinfantcareRecOrder int

	--=====================================================Here Check Childcare leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Childcare leave' and CompanyId=@CompanyId )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   ---Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,ApplyToAll,IsMOM,LeaveAccuralType)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Childcare leave','System',@Getdate,1,'Days','Selected',1,'Yearly'

	   ---Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
	
	--=====================================================Here Check Maternity leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Maternity leave' and CompanyId=@CompanyId )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   ---Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,ApplyToAll,IsMOM,LeaveAccuralType)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Maternity leave','System',@Getdate,1,'Days','Selected',1,'Yearly'

	   ---Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
		--=====================================================Here Check Paternity leaves IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Paternity leaves' and CompanyId=@CompanyId )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   ---Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,ApplyToAll,IsMOM,LeaveAccuralType)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Paternity leaves','System',@Getdate,1,'Days','Selected',1,'Yearly'

	   ---Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
			--=====================================================Here Check Unpaid infant care leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Unpaid infant care leave' and CompanyId=@CompanyId )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   ---Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,ApplyToAll,IsMOM,LeaveAccuralType)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Unpaid infant care leave','System',@Getdate,1,'Days','Selected',1,'Yearly'

	   ---Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END

	--================================================Here Getting Max StartDate in  HRSettingdetails Based on Company and CurrentYear====================
	set @HRSettingsStartDate=( 
	        select  MAX(B.StartDate)
		    from [Common].[HRSettings] A 
			Inner join [Common].[HRSettingdetails] B ON B.MasterId=A.Id
			Where A.CompanyId=@CompanyId AND YEAR(B.StartDate)=@CurrentYear
			)
	--================================================Here Getting Max EndDate in  HRSettingdetails Based on Company and CurrentYear====================
	set @HRSettingsEndDate=( 
	        select  MAX(B.EndDate)
		    from [Common].[HRSettings] A 
			Inner join [Common].[HRSettingdetails] B ON B.MasterId=A.Id
			Where A.CompanyId=@CompanyId AND YEAR(B.StartDate)=@CurrentYear
			)
	--================================================Here Getting  HRSettingdetailsId= in  HRSettingdetails Based on Company and CurrentYear====================
		set @HRSettingdetailsId=( 
	        select  TOP 1 B.Id
		    from [Common].[HRSettings] A 
			Inner join [Common].[HRSettingdetails] B ON B.MasterId=A.Id
			Where A.CompanyId=@CompanyId AND YEAR(B.StartDate)=@CurrentYear
			)


     SELECT @ChildcareLeaveTypeId,@HRSettingsStartDate,@HRSettingsEndDate,@HRSettingdetailsId
	--==========================================Here Check EmployeeId IF Exists or not Exists========================================
	IF Exists ( SELECT Id from [Common].[Employee] WHERE idtype IS NOT NULL AND isworkflowonly = 0 AND CompanyId = @CompanyId and status=1 and Id=@EmployeeId)
	BEGIN
	--=======================================Here EmployeeId IF Exists  Begin ==================================================
	       SET @ChildcareLeaveTypeId= (select Top 1 id from [HR].[LeaveType] where Name='Childcare leave' and CompanyId=@CompanyId)
		   SET @MaternityLeaveTypeId= (select Top 1 id from [HR].[LeaveType] where Name='Maternity leave' and CompanyId=@CompanyId)
		   SET @PaternityLeaveTypeId= (select Top 1 id from [HR].[LeaveType] where Name='Paternity leaves' and CompanyId=@CompanyId)
		   SET @UnpaidinfantcareLeaveTypeId= (select Top 1 id from [HR].[LeaveType] where Name='Unpaid infant care leave' and CompanyId=@CompanyId)

		   --========================================1.Check Childcare leave=============================================================
	---======== (Daughter OR Son ,Singapore Citizen,NIRC Pink,7 OR Between 7 and 12 ) (RelationShip,Nationality,IdType,DateOfBirth)===================
	    IF   (@ChildcareLeaveTypeId IS NOT NULL )  
	    Begin
		    IF Not Exists ( select Id from [HR].[LeaveEntitlement] Where EmployeeId=@EmployeeId and LeaveTypeId=@ChildcareLeaveTypeId and Year(StartDate)=@CurrentYear) 
		    BEGIN
	           IF Exists (
	           select Id from hr.FamilyDetails where EmployeeId=@EmployeeId AND RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,ROUND(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0,0))<7 AND IdType='NRIC(Pink)' and DateOfBirth is not null
	           )
		       BEGIN
		           set @ChildcareDays6=6
		       END
		       Else IF Exists (
	           select Id from hr.FamilyDetails where EmployeeId=@EmployeeId AND RelationShip in ('Son','Daughter') AND  Nationality='Singapore Citizen' 
	           AND CONVERT(int,ROUND(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0,0)) Between 7 and 12  AND IdType='NRIC(Pink)' and DateOfBirth is not null
	           )
		       BEGIN
		           set @ChildcareDays2=2
		       END
			      IF (@ChildcareDays6 IS NOT NULL AND @ChildcareDays2 IS NOT NULL AND @HRSettingdetailsId IS NOT NULL)
			      Begin
	                   SET @ChildcareRecOrder  = (select max(RecOrder) from [HR].[LeaveEntitlement] where EmployeeId=@EmployeeId and LeaveTypeId=@ChildcareLeaveTypeId)
		  	      
		  	            -- Insert into [HR].[LeaveEntitlement]  (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,RecOrder,UserCreated,CreatedDate,Status,StartDate,EndDate,Total,EntitlementStatus,HrSettingDetaiId)
		  	           select NewId(), @EmployeeId,@ChildcareLeaveTypeId,1,case when @ChildcareDays6 is null then @ChildcareDays2 else @ChildcareDays6 end ,ISNULL(@ChildcareRecOrder,0)+1,'System',@Getdate,1,@HRSettingsStartDate,@HRSettingsEndDate,case when @ChildcareDays6 is null then @ChildcareDays2 else @ChildcareDays6 END ,1,@HRSettingdetailsId
		          End
			END
        END

		--========================================2.'Maternity leave'============================================================= 
	    ---=============================(Female  ,'NRICPink' ) (Gender,IdType)==============================================
	    IF  (@MaternityLeaveTypeId IS NOT NULL )  
	    Begin
		    IF Not Exists ( select Id from [HR].[LeaveEntitlement] Where EmployeeId=@EmployeeId and LeaveTypeId=@MaternityLeaveTypeId and Year(StartDate)=@CurrentYear) 
		    BEGIN
	           IF Exists (
	           select Id from Common.Employee where Id=@EmployeeId AND Gender='Female'
	           )
		       BEGIN
		           set @MaternityDays= (select case when IdType='NRIC(Pink)'Then 112  else 84 end  from Common.Employee where Id=@EmployeeId AND Gender='Female')
		       END
			      IF (@MaternityDays IS NOT NULL AND @HRSettingdetailsId IS NOT NULL )
			      Begin
	                  SET @MaternityRecOrder  = (select max(RecOrder) from [HR].[LeaveEntitlement] where EmployeeId=@EmployeeId and LeaveTypeId=@MaternityLeaveTypeId)
		  		      
		  	           ---Insert into [HR].[LeaveEntitlement]  (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,RecOrder,UserCreated,CreatedDate,Status,StartDate,EndDate,Total,EntitlementStatus,HrSettingDetaiId)
		  	          select NewId(), @EmployeeId,@MaternityLeaveTypeId,1,@MaternityDays,ISNULL(@MaternityRecOrder,0)+1,'System',@Getdate,1,@HRSettingsStartDate,@HRSettingsEndDate,@MaternityDays,1,@HRSettingdetailsId
		          END
			END
        END

		--========================================3.'Paternity leaves'=============================================================
		--======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================
	    IF  (@PaternityLeaveTypeId IS NOT NULL )  
	    Begin
		    IF Not Exists ( select Id from [HR].[LeaveEntitlement] Where EmployeeId=@EmployeeId and LeaveTypeId=@PaternityLeaveTypeId and Year(StartDate)=@CurrentYear) 
		    BEGIN
	           IF Exists (
			     select Id from hr.FamilyDetails where EmployeeId=@EmployeeId AND RelationShip in ('Son','Daughter')  AND IdType='NRIC(Pink)' and EmployeeId  IN (
	             select Id from Common.Employee where Id=@EmployeeId AND Gender='Male')
	           )
		       BEGIN
		           set @PaternityDays=14
		       END
			      IF (@PaternityDays IS NOT NULL AND @HRSettingdetailsId IS NOT NULL )
			      Begin
	                  SET @PaternityRecOrder  = (select max(RecOrder) from [HR].[LeaveEntitlement] where EmployeeId=@EmployeeId and LeaveTypeId=@PaternityLeaveTypeId)
		  		      
		  	           ---Insert into [HR].[LeaveEntitlement]  (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,RecOrder,UserCreated,CreatedDate,Status,StartDate,EndDate,Total,EntitlementStatus,HrSettingDetaiId)
		  	          select NewId(), @EmployeeId,@PaternityLeaveTypeId,1,@PaternityDays,ISNULL(@PaternityRecOrder,0)+1,'System',@Getdate,1,@HRSettingsStartDate,@HRSettingsEndDate,@PaternityDays,1,@HRSettingdetailsId
		          END
			END
        END
		--========================================4.'Unpaid infant care leave'=============================================================
		--======================(Male,'Son','Daughter',NRICPink),(Gender,RelationShip,IdType)=======================================
	    IF  (@UnpaidinfantcareLeaveTypeId IS NOT NULL )  
	    Begin
		    IF Not Exists ( select Id from [HR].[LeaveEntitlement] Where EmployeeId=@EmployeeId and LeaveTypeId=@UnpaidinfantcareLeaveTypeId and Year(StartDate)=@CurrentYear) 
		    BEGIN
	           IF Exists (
			     select Id from hr.FamilyDetails where EmployeeId=@EmployeeId AND RelationShip in ('Son','Daughter')  AND IdType='NRIC(Pink)' 
				 AND CONVERT(int,ROUND(DATEDIFF(hour,DateOfBirth,@Getdate)/8766.0,0))<2
	           )
		       BEGIN
		           set @UnpaidinfantcareDays=6
		       END
			      IF (@UnpaidinfantcareDays IS NOT NULL AND @HRSettingdetailsId IS NOT NULL )
			      Begin
	                  SET @UnpaidinfantcareRecOrder  = (select max(RecOrder) from [HR].[LeaveEntitlement] where EmployeeId=@EmployeeId and LeaveTypeId=@UnpaidinfantcareLeaveTypeId)
		  		      
		  	           ---Insert into [HR].[LeaveEntitlement]  (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,RecOrder,UserCreated,CreatedDate,Status,StartDate,EndDate,Total,EntitlementStatus,HrSettingDetaiId)
		  	          select NewId(), @EmployeeId,@UnpaidinfantcareLeaveTypeId,1,@UnpaidinfantcareDays,ISNULL(@UnpaidinfantcareRecOrder,0)+1,'System',@Getdate,1,@HRSettingsStartDate,@HRSettingsEndDate,@UnpaidinfantcareDays,1,@HRSettingdetailsId
		          END
			END
        END
	END
End
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_Leavetype_2_Entitlement]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  --sp_helptext [SP_HR_Leavetype_2_Entitlement]
   
 CREATE Procedure  [dbo].[SP_HR_Leavetype_2_Entitlement](@leaveTypeId UNIQUEIDENTIFIER,@companyId BIGINT,@applytoAll NVARCHAR(50),@isChanged NVARCHAR(15),@LeaveruleEngineId UNIQUEIDENTIFIER null)  
AS   
BEGIN             
Declare @employeeId  UNIQUEIDENTIFIER,  
  @HrSettingDetailId UNIQUEIDENTIFIER,  
  @userCreated Nvarchar(256),  
  @modifiedby Nvarchar(256),  
  @annualLeaveEntitlement float,  
  @carryForwardDays float,  
  @prorated float=0,  
  @futureprorated float=0,  
  @entitlementHours float=0,  
  @remainingProrated float=0,  
  @leaveAccuralType Nvarchar(100),  
  @entitlementType Nvarchar(100),  
  @createdDate DATETIME2(7),  
  @startDate DATETIME2(7),  
  @enddate DATETIME2(7),  
  @resetDate DATETIME2(7),  
  @EMPSTARTDATE DATETIME2(7),  
  @YearDate DATETIME,      
  @OriginalStartDate DATETIME,      
  @deptId  UNIQUEIDENTIFIER,  
  @deptDesignationId  UNIQUEIDENTIFIER,  
  @id  UNIQUEIDENTIFIER,  
  @OldEntitlement float=0,  
  @OldLeaveBalance float=0,  
  @OldCarryForwardDays float=0,  
  @ACCURALLEAVE  INT=0,     
  @ACCURALDAYS  INT=0,    
  @MONTHSTARTDATE DateTime,    
  @TestPRORATED FLOAT=0,      
        @DIFFMONTH  FLOAT=0.0,  
  @status INT,  
  @IsNotRequiredApprover Bit,  
  @IsNotRequiredRecommender Bit,
  @Effectivefrom Datetime;
    
  
 BEGIN Transaction--mt  
 BEGIN TRY--m0   
                --here startdate and end date  
    SELECT TOP (1) @HrSettingDetailId=hrd.Id,@resetDate=hrd.EndDate,@OriginalStartDate=hrd.StartDate,@startDate=hrd.StartDate ,@enddate=hrd.EndDate from Common.HRSettingdetails as hrd (NOLOCK) where MasterId in (select Id from Common.HRSettings (NOLOCK) where CompanyId=@companyId)   order by StartDate desc  
                --here entitlement,usercredted,modifiedby,createddate  
       SELECT @userCreated=lt.UserCreated,@modifiedby=lt.ModifiedBy,@ACCURALDAYS=isnull(AccuralDays, 0),@leaveAccuralType=lt.LeaveAccuralType,@entitlementType=lt.EntitlementType,@entitlementHours=lt.EntitlementHours,@createdDate=lt.CreatedDate from HR.LeaveType as lt (NOLOCK) where Id=@leaveTypeId  
  
      --here startdate and end date  
   if(@applytoAll!='Rule Based')  
   begin   
   delete from [HR].[LeaveRuleEngineEmployee] where [LeaveRuleEngineId] in (select id from [HR].[LeaveRuleEngine] (NOLOCK) where leavetypeid=@leaveTypeId)  
   delete from [HR].[LeaveRuleEngine] where [LeaveTypeId] =@leaveTypeId  
   end   
   
     If(@applytoAll = 'All')--loop1  
   BEGIN--1  
       select @annualLeaveEntitlement=Entitlement,@carryForwardDays=CarryForwardDays from HR.LeaveTypeDetails (NOLOCK) where LeaveTypeId=@leaveTypeId  
  
      DECLARE lstEmployees CURSOR FOR SELECT e.Id,ment.StartDate, empd.EffectiveFrom from Common.Employee  as e (NOLOCK) join HR.Employment as ment (NOLOCK) on ment.EmployeeId=e.Id join Hr.EmployeeDepartment as empd on e.Id=empd.EmployeeId
	  where e.CompanyId=@companyId and e.status=1 and e.IdType is not null and (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and (Convert(Date,EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null))   
      OPEN lstEmployees  
      FETCH NEXT FROM lstEmployees INTO @employeeId,@EMPSTARTDATE ,@Effectivefrom
      WHILE @@FETCH_STATUS = 0  
       BEGIN --2  
  
        select TOP (1) @IsNotRequiredApprover = IsNotRequiredApprover,@IsNotRequiredRecommender=IsNotRequiredRecommender from HR.LeaveEntitlement (NOLOCK) where EmployeeId=@employeeId  and status=1 and HrSettingDetaiId = @HrSettingDetailId and IsNotRequiredApprover is not null and IsNotRequiredRecommender is not null  
           -- for future prorated  
          SET @STARTDATE =@OriginalStartDate;  
         If(@leaveAccuralType = 'Yearly with proration')      
          BEGIN    --3  
           -- for future prorated    
           SET @STARTDATE=CASE WHEN CONVERT(DATE,@Effectivefrom) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @Effectivefrom END;       
           --SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
           SET @YearDate =@STARTDATE;  
           SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
           SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
  
           SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
           SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;     
           Select @PRORATED=value1 From SplitDecimalValue(@TestPRORATED);  
           Select @FuturePRORATED=@PRORATED;  
          END    --3  
        ELSE If(@leaveAccuralType = 'Yearly without proration')      
          BEGIN   --4   
           Select @prorated=@annualLeaveEntitlement;  
           Select @FuturePRORATED=@PRORATED;  
          END  --4  
        ELSE If(@leaveAccuralType = 'Monthly' )      
          BEGIN   --5   
           SET @STARTDATE=CASE WHEN CONVERT(DATE,@Effectivefrom) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @Effectivefrom END;   
		   print @STARTDATE
           SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;  
		   print @YearDate
           SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END; 
		   print @ACCURALLEAVE
           --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE())));   
           if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@YearDate))  
   begin  
   set @ACCURALLEAVE=0  
   print '@ACCURALLEAVE'
   end   
  
  
           SET @DIFFMONTH =CASE WHEN CONVERT(DATE,getdate()) < CONVERT(DATE,@YearDate) Then 0 else  (SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))) END;   
             
  print @DIFFMONTH
  
           SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);   
		   print @DIFFMONTH
           SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;  
		   print @TestPRORATED
           Select @PRORATED=value1,@REMAININGPRORATED=value2 From SplitDecimalValue(@TestPRORATED)
		   print @PRORATED
          -- for future prorated  
           SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
           SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE); 
		   print @DIFFMONTH
           SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;  
		   print @TestPRORATED
           Select @FuturePRORATED=value1 From SplitDecimalValue(@TestPRORATED)   
		   print @FuturePRORATED
          END  --5  
        IF NOT EXISTS (select Id from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and HrSettingDetaiId =@HrSettingDetailId)--loop2  ---> Adding HR Setting Detail Id by Raju 13 Dec 2024
         BEGIN--6  
          INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
          Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId, IsNotRequiredApprover,IsNotRequiredRecommender)   
          VALUES   
          (NEWID(),@employeeId,@leaveTypeId,1,@annualLeaveEntitlement,null,null,@prorated,0,0,null,1,  
          @userCreated,GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
          @prorated, @prorated,@prorated,@carryForwardDays,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsNotRequiredApprover,@IsNotRequiredRecommender)  
         END--6  
        ELSE--loop3  
         BEGIN--7  
         --Print 'Update'  
         select @OldCarryForwardDays=CarryForwardDays,@status=Status,@OldEntitlement=AnnualLeaveEntitlement,@OldLeaveBalance=LeaveBalance from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and Status=1  
           IF(@leaveAccuralType = 'Monthly')  
             BEGIN--8  
              update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
              Prorated=@PRORATED,  
              [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
              LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
              YTDLeaveBalance=(isnull(@FuturePRORATED,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
              Adjusted = (CASE WHEN (Adjustment != null) THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
              Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
              CarryForwardDays=@carryForwardDays,  
              FutureProrated=@FuturePRORATED  
              where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
             END--8  
          ELSE IF(@leaveAccuralType = 'Yearly with proration')  
            BEGIN--9  
             update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
             Prorated=@prorated,  
             [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
             LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
             YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
             Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
             Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
             CarryForwardDays=@carryForwardDays,  
             FutureProrated=@futureprorated  
             where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
            END--9  
         ELSE IF(@leaveAccuralType = 'Yearly without proration')  
            BEGIN--10  
             update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
             Prorated=@prorated,  
             [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
             LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
             YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
             Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
             Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
             CarryForwardDays=@carryForwardDays,  
             FutureProrated=@futureprorated  
             where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
            END--10  
         END--7--loop3  
      FETCH NEXT FROM lstEmployees INTO  @employeeId,@EMPSTARTDATE  ,@EffectiveFrom 
      END--2  
     CLOSE lstEmployees  
     DEALLOCATE lstEmployees  
   END --1   
 else If(@applytoAll = 'Selected')--loop1  
  BEGIN --11  
    DECLARE lstDeptandDesignations CURSOR FOR select Id,DepartmentId,DesignationId from HR.LeaveTypeDetails (NOLOCK) where LeaveTypeId=@leaveTypeId  
       OPEN lstDeptandDesignations  
        FETCH NEXT FROM lstDeptandDesignations INTO @id,@deptId,@deptDesignationId  
        WHILE @@FETCH_STATUS = 0  
         BEGIN --12  
                IF(@deptDesignationId is null and @deptId is not null)  
           BEGIN  
            select @annualLeaveEntitlement=Entitlement,@carryForwardDays=CarryForwardDays from HR.LeaveTypeDetails (NOLOCK) where LeaveTypeId=@leaveTypeId and DepartmentId=@deptId and  DesignationId is null  
            END  
  
           IF(@deptDesignationId is not null and @deptId is null)  
           BEGIN  
            
           select @annualLeaveEntitlement=Entitlement,@carryForwardDays=CarryForwardDays from HR.LeaveTypeDetails (NOLOCK) where LeaveTypeId=@leaveTypeId and DepartmentId is null and  DesignationId =@deptDesignationId  
           END  
  
            IF(@deptDesignationId is not null and @deptId is not null)  
            BEGIN  
  
               select @annualLeaveEntitlement=Entitlement,@carryForwardDays=CarryForwardDays from HR.LeaveTypeDetails (NOLOCK) where LeaveTypeId=@leaveTypeId and DepartmentId=@deptId and  DesignationId=@deptDesignationId  
            END  
             
               
              IF(@deptDesignationId is null and @deptId is not null)  
              Begin--15  
             DECLARE lstEmployees CURSOR FOR   
             select empdt.EmployeeId,ment.StartDate,empdt.EffectiveFrom from hr.EmployeeDepartment as empdt (NOLOCK) join common.Employee as e (NOLOCK)  on empdt.EmployeeId=e.id join HR.Employment as ment (NOLOCK)  
             on e.Id = ment.EmployeeId where (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE())) and e.status=1 and  e.IdType is not null and empdt.DepartmentId= @deptId   
              and  e.companyid=@companyId and (Convert(Date,EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null))  
              End--15  
  
               IF(@deptDesignationId is not null and @deptId is null)--parvathi  
               Begin--15  
             DECLARE lstEmployees CURSOR FOR   
             select empdt.EmployeeId,ment.StartDate,empdt.EffectiveFrom from hr.EmployeeDepartment as empdt (NOLOCK) join common.Employee as e (NOLOCK)  on empdt.EmployeeId=e.id join HR.Employment as ment (NOLOCK)  
             on e.Id = ment.EmployeeId where (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE())) and  e.IdType is not null   and e.status=1
              and  e.companyid=@companyId  and (Convert(Date,EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null)) and empdt.DepartmentDesignationId in (select Id from common.DepartmentDesignation (NOLOCK) where Code=(select Code from common.DepartmentDesignation (NOLOCK) where Id=@deptDesignationId))  
              End--15  
  
             --  IF(@deptDesignationId is null and @deptId is null)--parvathi  
             --  Begin--15  
             --DECLARE lstEmployees CURSOR FOR   
             --select empdt.EmployeeId,ment.StartDate from hr.EmployeeDepartment as empdt join common.Employee as e  on empdt.EmployeeId=e.id join HR.Employment as ment  
             --on e.Id = ment.EmployeeId where (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE())) and  e.IdType is not null   
             -- and  e.companyid=@companyId   
             -- End--15  
  
             ELSE IF(@deptDesignationId is not null and @deptId is not null)  
              Begin--16  
             DECLARE lstEmployees CURSOR FOR   
             select empdt.EmployeeId,ment.StartDate,empdt.EffectiveFrom from hr.EmployeeDepartment as empdt (NOLOCK) join common.Employee as e (NOLOCK)  on empdt.EmployeeId=e.id join HR.Employment as ment (NOLOCK)  
             on e.Id = ment.EmployeeId where (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and (Convert(Date,ment.StartDate) <= Convert(date,GETDATE()))  and  e.IdType is not null and e.status=1 and  empdt.DepartmentId=@deptId   
             and empdt.DepartmentDesignationId =@deptDesignationId and  e.companyid=@companyId  and   
             (Convert(Date,EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null))  
              End--16  
  
            OPEN lstEmployees  
             FETCH NEXT FROM lstEmployees INTO @employeeId,@EMPSTARTDATE  ,@Effectivefrom
             WHILE @@FETCH_STATUS = 0  
              BEGIN--17   
                  SET @STARTDATE =@OriginalStartDate;  
                   If(@leaveAccuralType = 'Yearly with proration')      
                  BEGIN --18     
                   -- for future prorated    
                   SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
                   --SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
                   SET @YearDate =@STARTDATE;  
                   SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
                   SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
  
                   SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
                   SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;     
                   Select @PRORATED=value1 From SplitDecimalValue(@TestPRORATED);  
                   Select @FuturePRORATED=@PRORATED;  
                  END   --18   
                Else If(@leaveAccuralType = 'Yearly without proration')      
                  BEGIN    --19  
                   Select @PRORATED=@annualLeaveEntitlement;  
                   Select @FuturePRORATED=@PRORATED;  
                  END    --19  
                ELSE If(@leaveAccuralType = 'Monthly')      
                  BEGIN    --20  
                   SET @STARTDATE=CASE WHEN CONVERT(DATE,@Effectivefrom) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @Effectivefrom END;
				   print @STARTDATE
                   SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE  @startDate END; 
				   print @YearDate
                   SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;   
				   print @ACCURALLEAVE
                   --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE())));   
                   if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@YearDate))  
   begin  
   set @ACCURALLEAVE=0 
   print '@ACCURALLEAVE'
   end   
                   SET @DIFFMONTH =CASE WHEN CONVERT(DATE,getdate()) < CONVERT(DATE,@YearDate) Then 0 else  (SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))) END;   
                   SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
				   print @DIFFMONTH
                   SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;  
				   print @TestPRORATED
                   Select @PRORATED=value1,@REMAININGPRORATED=value2 From SplitDecimalValue(@TestPRORATED) 
				   print @PRORATED
                  -- for future prorated  
                   --SET @MONTHSTARTDATE=(SELECT DateAdd(MONTH,1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)));  
                   SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
                   SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
				   print @DIFFMONTH
                   SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0; 
				   print @TestPRORATED
                   Select @FuturePRORATED=value1 From SplitDecimalValue(@TestPRORATED)  
				   print @FuturePRORATED
                  END    --20  
  
               IF NOT EXISTS (select Id from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and HrSettingDetaiId = @HrSettingDetailId) ---> Adding HR Setting Detail Id by Raju 13 Dec 2024
               Begin--21  
                INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
                Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
                VALUES   
                (NEWID(),@employeeId,@leaveTypeId,1,@annualLeaveEntitlement,null,null,@prorated,0,0,null,1,  
                @userCreated,GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
                @prorated, @prorated,@futureprorated,@carryForwardDays,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsNotRequiredApprover,@IsNotRequiredRecommender)         
               END--21  
               ELSE  
               Begin--22  
               --Print 'Update'  
               select  @OldCarryForwardDays=CarryForwardDays,@status=Status,@OldEntitlement=AnnualLeaveEntitlement,@OldLeaveBalance=LeaveBalance from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and Status=1   
                    -- for future prorated  
                IF(@leaveAccuralType = 'Monthly')  
                 BEGIN--23  
                 update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
                 Prorated=@PRORATED,  
                 [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
                 LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 YTDLeaveBalance=(isnull(@FuturePRORATED,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 Adjusted = (CASE WHEN (Adjustment != null) THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
                 Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
                 CarryForwardDays=@carryForwardDays,  
                 FutureProrated=@FuturePRORATED  
                 where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
                 END--23  
                                                             IF(@leaveAccuralType = 'Yearly with proration')  
                BEGIN--24  
                 update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
                 Prorated=@prorated,  
                 [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
                 LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
                 Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
                 CarryForwardDays=@carryForwardDays,  
                 FutureProrated=@futureprorated  
                 where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
                END--24  
               IF(@leaveAccuralType = 'Yearly without proration')  
                BEGIN--25  
                 update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
                 Prorated=@prorated,  
                 [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
                 LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
                 Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
                 Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
                 CarryForwardDays=@carryForwardDays,  
                 FutureProrated=@futureprorated  
                 where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
                END--25  
               End--22  
              FETCH NEXT FROM lstEmployees INTO @employeeId,@EMPSTARTDATE ,@EffectiveFrom 
              END--17  
          CLOSE lstEmployees  
          DEALLOCATE lstEmployees  
  
         FETCH NEXT FROM lstDeptandDesignations INTO @id,@deptId,@deptDesignationId  
         END--12  
    CLOSE lstDeptandDesignations  
    DEALLOCATE lstDeptandDesignations        
  END--11  
 ELSE   
  BEGIN    
   DECLARE lstEmployees CURSOR FOR   
   SELECT e.Id,ment.StartDate,lre.NoOfDays  from Common.Employee as e (NOLOCK) join HR.Employment as ment (NOLOCK) on ment.EmployeeId=e.Id join hr.LeaveRuleEngineEmployee as lre (NOLOCK)  
   on lre.EmployeeId=e.Id where e.CompanyId=@companyId and e.IdType is not null and (Convert(Date,ment.StartDate) < Convert(date,@resetDate)) and lre.LeaveRuleEngineId=@LeaveruleEngineId  
  
     OPEN lstEmployees  
      FETCH NEXT FROM lstEmployees INTO @employeeId,@EMPSTARTDATE,@annualLeaveEntitlement  
      WHILE @@FETCH_STATUS = 0  
       BEGIN--17   
        SET @STARTDATE =@OriginalStartDate;  
         If(@leaveAccuralType = 'Yearly with proration')      
           BEGIN --18     
            -- for future prorated    
            SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
            --SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
            SET @YearDate =@STARTDATE;  
            SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
            SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
  
            SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);  
            SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;     
            Select @PRORATED=value1 From SplitDecimalValue(@TestPRORATED);  
            Select @FuturePRORATED=@PRORATED;  
           END   --18   
         Else If(@leaveAccuralType = 'Yearly without proration')      
           BEGIN    --19  
            Select @PRORATED=@annualLeaveEntitlement;  
            Select @FuturePRORATED=@PRORATED;   
           END    --19  
         ELSE If(@leaveAccuralType = 'Monthly')      
           BEGIN    --20  
            SET @STARTDATE=CASE WHEN CONVERT(DATE,@EMPSTARTDATE) < CONVERT(DATE,@STARTDATE)  THEN @STARTDATE ELSE @EMPSTARTDATE END;       
            SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@createdDate)  THEN @createdDate ELSE @STARTDATE END;      
            SET @ACCURALLEAVE= CASE WHEN (DAY(EOMONTH(@YearDate)) -DATEPART(DAY,@YearDate) +1) >= @ACCURALDAYS THEN 0 ELSE -1 END;      
            --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE())));  
            if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@YearDate))  
   begin  
   set @ACCURALLEAVE=0  
   end   
            SET @DIFFMONTH =CASE WHEN CONVERT(DATE,getdate()) < CONVERT(DATE,@YearDate) Then 0 else  (SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))) END;   
            SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
            SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;                   
            Select @PRORATED=value1,@REMAININGPRORATED=value2 From SplitDecimalValue(@TestPRORATED)         
           -- for future prorated  
            --SET @MONTHSTARTDATE=(SELECT DateAdd(MONTH,1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)));  
            SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,@RESETDATE)));   
            SET @DIFFMONTH=@DIFFMONTH+(@ACCURALLEAVE);     
            SET @TestPRORATED=(@DIFFMONTH*@annualLeaveEntitlement)/12.0;     
            Select @FuturePRORATED=value1 From SplitDecimalValue(@TestPRORATED)    
           END    --20  
  
        IF NOT EXISTS (select Id from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and HrSettingDetaiId = @HrSettingDetailId) ---> Adding HR Setting Detail Id by Raju 13 Dec 2024 
        Begin--21  
         INSERT INTO  HR.LeaveEntitlement (Id,EmployeeId,LeaveTypeId,IsApplicable,AnnualLeaveEntitlement,LeaveApprovers, LeaveRecommenders,Prorated,ApprovedAndTaken,ApprovedAndNotTaken,Remarks,RecOrder,UserCreated,CreatedDate, ModifiedBy,ModifiedDate,Version,Status,StartDate,EndDate,BroughtForward,IsEnableLeaveRecommender,Adjustment,  
         Adjusted,CompletedMonth,RemainingProrated,[Current],LeaveBalance,Total,CarryForwardDays,Entitlementstatus,YTDLeaveBalance,FutureProrated,HrSettingDetaiId,IsNotRequiredApprover,IsNotRequiredRecommender)   
         VALUES   
         (NEWID(),@employeeId,@leaveTypeId,1,@annualLeaveEntitlement,null,null,@prorated,0,0,null,1,  
         @userCreated,GETUTCDATE(),null,null,2,1,@startDate,@enddate,0,0,null,null,(DATEPART(m, GETUTCDATE())),@remainingProrated,  
         @prorated, @prorated,@futureprorated,@carryForwardDays,1,@futureprorated,@futureprorated,@HrSettingDetailId,@IsNotRequiredApprover,@IsNotRequiredRecommender)         
        END--21  
        ELSE  
        Begin--22  
        --Print 'Update'  
        select  @OldCarryForwardDays=CarryForwardDays,@status=Status,@OldEntitlement=AnnualLeaveEntitlement,@OldLeaveBalance=LeaveBalance from HR.LeaveEntitlement (NOLOCK) where employeeid=@employeeId and Leavetypeid=@leaveTypeId and Status=1   
             -- for future prorated  
         IF(@leaveAccuralType = 'Monthly')  
          BEGIN--23  
          update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
          Prorated=@PRORATED,  
          [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
          LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          YTDLeaveBalance=(isnull(@FuturePRORATED,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          Adjusted = (CASE WHEN (Adjustment != null) THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
          Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
          CarryForwardDays=@carryForwardDays,  
          FutureProrated=@FuturePRORATED  
          where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
          END--23  
                                    IF(@leaveAccuralType = 'Yearly with proration')  
         BEGIN--24  
          update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
          Prorated=@prorated,  
          [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
          LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
          Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
          CarryForwardDays=@carryForwardDays,  
          FutureProrated=@futureprorated  
          where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
         END--24  
        IF(@leaveAccuralType = 'Yearly without proration')  
         BEGIN--25  
          update HR.LeaveEntitlement set AnnualLeaveEntitlement=@annualLeaveEntitlement,  
          Prorated=@prorated,  
          [Current]=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0)),  
          LeaveBalance=(isnull(@prorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          YTDLeaveBalance=(isnull(@futureprorated,0)+isnull(BroughtForward,0)+isnull(Adjustment,0))-((isnull(ApprovedAndTaken,0)+isnull(ApprovedAndNotTaken,0))),  
          Adjusted = (CASE WHEN Adjustment != null THEN isnull(@annualLeaveEntitlement,0)+isnull(Adjustment,0) ELSE NULL END),  
          Total=isnull(@annualLeaveEntitlement,0)+isnull(BroughtForward,0)+isnull(Adjustment,0),  
          CarryForwardDays=@carryForwardDays,  
          FutureProrated=@futureprorated  
          where EmployeeId=@employeeId and LeaveTypeId=@leaveTypeId and Status=1  
         END--25  
        End--22  
       FETCH NEXT FROM lstEmployees INTO @employeeId,@EMPSTARTDATE,@annualLeaveEntitlement  
       END--17  
   CLOSE lstEmployees  
   DEALLOCATE lstEmployees  
  
  END--12  
   
  
 COMMIT TRANSACTION  
  
END TRY  
BEGIN CATCH  
  
ROLLBACK TRANSACTION  
DECLARE @ERRORMESSAGE NVARCHAR(4000),  
  @ERRORSEVERITY INT,  
  @ERRORSTATE INT;  
 SELECT  
 @ERRORMESSAGE = ERROR_MESSAGE(),  
 @ERRORSEVERITY = ERROR_SEVERITY(),  
 @ERRORSTATE = ERROR_STATE();  
 RAISERROR (@ERRORMESSAGE,@ERRORSEVERITY,@ERRORSTATE);  
  
END CATCH  
END  
GO

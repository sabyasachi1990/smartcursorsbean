USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SchedulerCaseTaskReplicateNew1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--====Alter====================================================================08 ==================================================================    
--====Alter====================================================================08 ==================================================================    
CREATE Procedure [dbo].[SchedulerCaseTaskReplicateNew1]     
@ScheduleId Uniqueidentifier,    
@CaseId Uniqueidentifier,    
@FromEmpId Uniqueidentifier,    
@ToEmpId Uniqueidentifier,    
@IsOverRun Int    
As    
Begin    
       Declare @ErrMsg Nvarchar(250),    
  @EmpName Nvarchar(500)    
   Begin Transaction    
      Begin Try    
        Declare @FromScheduleDtlId Uniqueidentifier,    
  @PlanedHours Int,    
  @ScheduleTaskId Uniqueidentifier,    
  @ScheduleDetailId Uniqueidentifier,    
  @ScheduletaskStartdate DateTime2,    
  @ScheduletaskEnddate DateTime2,    
  @From_STHours int,    
  @From_IsOvrRunHours int,    
  @From_TotalHours int,    
  @Title nvarchar(500),    
  @IsOverRun1 Int,    
  @CompanyId INT    
    
--//*============================================Declare Second Cursor To get Schedule Tasks Of From Employee =======================================*//    
         Declare ScheduleTaskCsr Cursor For    
   Select st.Id,st.ScheduleDetailId,st.StartDate,st.EndDate,st.PlannedHours,st.OverRunHours,st.IsOverRun,st.Task,ST.CompanyId From WorkFlow.ScheduleTaskNew st    
   inner join WorkFlow.ScheduleDetailNew sd on sd.id=st.ScheduleDetailId    
   inner join WorkFlow.ScheduleNew s on s.id=sd.MasterId    
   Where st.CaseId=@CaseId and st.EmployeeId=@FromEmpId  and s.id=@ScheduleId   order by st.StartDate    
         Open ScheduleTaskCsr    
         Fetch Next From ScheduleTaskCsr Into @ScheduleTaskId,@ScheduleDetailId,@ScheduletaskStartdate,@ScheduletaskEnddate,@From_STHours,@From_IsOvrRunHours,@IsOverRun1,@Title,@CompanyId    
      While @@FETCH_STATUS=0    
   Begin ----2 Second Cursor    
       Declare @DepartMentId Uniqueidentifier,    
    @DeptDesgId Uniqueidentifier,    
    @LevelRank Int,    
    @ChargeOutRate Nvarchar(50),    
    @ToScheduleDtlId Uniqueidentifier,    
    @SDId_ST Uniqueidentifier,    
    @To_STHours int,    
    @To_STIsOvrRunHours int,    
    @Count Int,    
    @Updt_ST_Hours int,    
    @Updt_ST_IsovrRunHrs int,    
    @CaseScheduleDtlId Uniqueidentifier    
        
         
--//* ======================================================    Checking ToEmployee Is Active or not in From Employee task satrt date  ==========================================    
                Select @Count=COUNT(*) From HR.EmployeeDepartment --Where EmployeeId=@ToEmpId --And EffectiveFrom >= @ScheduletaskStartdate     
       --And @ScheduletaskStartdate between EffectiveFrom And Isnull(EffectiveTo,EffectiveFrom)    
       Where EmployeeId=@ToEmpId And EffectiveFrom <= @ScheduletaskStartdate and (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null)     
     set @ScheduletaskStartdate =  [dbo].[CheckDateAvalibility](@ScheduletaskStartdate,@CaseId,@CompanyId,@ToEmpId)     
    
            If @Count<>0    
         Begin  --=======3rd    
              Select @DepartMentId=DepartmentId,@DeptDesgId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate     
              From HR.EmployeeDepartment     
              Where EmployeeId=@ToEmpId And EffectiveFrom <= @ScheduletaskStartdate and (@ScheduletaskStartdate <= EffectiveTo  or EffectiveTo is null)     
            --And @ScheduletaskStartdate between EffectiveFrom And Isnull(EffectiveTo,EffectiveFrom)    
      Set @ToScheduleDtlId =(      
                                 select Distinct  SD.Id from WorkFlow.ScheduleDetailNew SD    
                                                     INNER JOIN WorkFlow.ScheduleNew S ON S.Id=SD.MasterId    
                                                    WHERE S.CaseId=@CaseId AND     
             EmployeeId=@ToEmpId          
                                                    And  MasterId = @ScheduleId    
            )    
    --//*======================================= If To Employee having task on that date update details with from employee =====================================================    
               If Exists (Select * from WorkFlow.ScheduleTaskNew Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and ScheduleDetailId=@ToScheduleDtlId    
       and caseid=@CaseId  and task=@Title)    
            Begin --5th IF Exists ST        
                Select @SDId_ST=ScheduleDetailId,@To_STHours=PlannedHours,@To_STIsOvrRunHours=OverrunHours From WorkFlow.ScheduleTaskNew Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and ScheduleDetailId=@ToScheduleDtlId    
          and caseid=@CaseId  and task=@Title    
           --Begin--==    
           --   Select @EmpName=FirstName From Common.Employee Where Id=@ToEmpId    
           --   Set @ErrMsg = Concat(@EmpName,' Hours Exceeded ','On ',Convert(VARCHAR,@ScheduletaskStartdate ,103))    
           --    Set @Updt_ST_Hours=  Isnull(@From_STHours,0)+Isnull(@To_STHours,0)    
           -- End--==    
                Set @Updt_ST_IsovrRunHrs= Isnull(@From_IsOvrRunHours,0)+Isnull(@To_STIsOvrRunHours,0)     
--//*======================================================== Update Schedule Task table based on conditions ====================================================================    
         
                Update  WorkFlow.ScheduleTaskNew Set PlannedHours=@Updt_ST_Hours,OverrunHours= case when @IsOverRun=1 then @Updt_ST_IsovrRunHrs     
           else OverrunHours end     
       ,ScheduleDetailId=@ToScheduleDtlId,IsOverRun=case when @IsOverRun=1 then 1 else IsOverRun End,ChargeoutRate=@ChargeOutRate    
          Where EmployeeId=@ToEmpId And StartDate=@ScheduletaskStartdate and ScheduleDetailId=@ToScheduleDtlId    
          and caseid=@CaseId  and task=@Title    
         End --5th IF Exists ST       
--//*========================================================== If To Employee Doesn't have task on that date update details with from employee ==================================    
            Else    
      Begin    
       Insert Into WorkFlow.ScheduleTaskNew    
                            (Id,CompanyId,CaseId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,StartDate,EndDate,    
       IsOverRun,PlannedHours,OverRunHours,Task,ChargeoutRate,Remarks,Status,Level)    
                Select NEWID(),CompanyId,@CaseId,@ToScheduleDtlId,@DepartMentId,@DeptDesgId,@ToEmpId,@ScheduletaskStartdate,@ScheduletaskStartdate,    
       case when @IsOverRun=1 then IsOverRun else 0 End as IsOverRun,PlannedHours, case when @IsOverRun=1 then OverrunHours    
            end as OverrunHours  ,Task,@ChargeOutRate,Remarks,Status,@LevelRank    
                From WorkFlow.ScheduleTaskNew Where Id=@ScheduleTaskId    
    
               End -- 5th IF Not  Exists ST    
    
  --=============================================== //// Error throw while exeed day hours    
      --            Begin --==     
      --                      Declare @HT  decimal(28,2),@Exd_Hours decimal(28,2),@THrs decimal(28,2),@ExdHrsDate date    
      --                Declare ExdHrs_CSR Cursor For    
    
      --                Select cast(sum(Isnull(PlannedHours,0)) as decimal(28,2))  as PlannedHours,StartDate From WorkFlow.ScheduleTaskNew      
      --                Where  EmployeeId=@ToEmpId And  StartDate=@ScheduletaskStartdate and ScheduleDetailId=@ToScheduleDtlId    
      -- AND CaseId=@CaseId     
      -- Group by StartDate order by StartDate    
    
      --                Open ExdHrs_CSR    
      --                Fetch Next From ExdHrs_CSR Into @HT,@ExdHrsDate    
      --                While @@FETCH_STATUS=0    
      --                Begin --    
      --                     Select @Exd_Hours=CASE WHEN Cast((@HT)/60 As decimal(28,2)) >= 60 THEN    
      --                                          Cast(Cast((@HT)/60 As decimal(28,2)) / 60 As Varchar) + '.' +    
      --                                    Case When (Cast((@HT)/60 As decimal(28,2)) % 60) < 10 Then    
      --                                 '0'+Cast (Cast ((@HT)/60As decimal(28,2)) % 60 As varchar)     
      --                                  Else    
      --       Cast(Cast((@HT)/60 As decimal(28,2)) % 60 As varchar)    
      --       End    
      --       Else    
      --       Cast( Cast ((@HT)/60 As decimal(28,2)) % 60  As varchar) End    
      
      --                     Set @THrs=@Exd_Hours  ----- cast(Substring(@Exd_Hours,1,Isnull(CHARINDEX('.',@Exd_Hours),len(@Exd_Hours)-1)) As float)    
    
      --                    If @THrs>23.99    
      --                    Begin --==    
      --                       Select @EmpName=FirstName From Common.Employee Where Id=@ToEmpId    
      --                       Set @ErrMsg = Concat(@EmpName,' Hours Exceeded ','On ',Convert(VARCHAR,@ExdHrsDate ,103))     
      --                       RAISERROR(@ErrMsg,16,1)    
      --                    End --    
      --                    Fetch Next From ExdHrs_CSR Into @HT,@ExdHrsDate    
      --                End --    
      --                Close ExdHrs_CSR    
      --                Deallocate ExdHrs_CSR    
      --END    
      -----------    
                End     
              Fetch Next From ScheduleTaskCsr Into @ScheduleTaskId,@ScheduleDetailId,@ScheduletaskStartdate,@ScheduletaskEnddate,@From_STHours,@From_IsOvrRunHours,@IsOverRun1,@Title,@CompanyId    
    
         End ----1ts Cursor    
            Close ScheduleTaskCsr -- 1 ts Cursor    
            Deallocate ScheduleTaskCsr -- 1 ts Cursor    
    
    
    
   Begin    
   --  DECLARE @MINDATE DateTime2,    
   --  @MAXDATE DateTime2    
   --    SELECT @MINDATE=MIN(ST.StartDate), @MAXDATE=MAX(ST.EndDate) From WorkFlow.ScheduleDetailNew  SD    
   --INNER JOIN WorkFlow.ScheduleTaskNew  ST ON SD.ID=ST.ScheduleDetailId AND SD.EmployeeId=ST.EmployeeId    
   --   Where caseId=CaseId and ST.EmployeeId=@ToEmpId     
   --  and  SD.MasterId=@ScheduleId    
    
    
   --   UPDATE SD SET SD.StartDate= @MINDATE ,SD.EndDate=@MAXDATE From WorkFlow.ScheduleDetailNew  SD    
   --INNER JOIN WorkFlow.ScheduleTaskNew  ST ON SD.ID=ST.ScheduleDetailId AND SD.EmployeeId=ST.EmployeeId    
   --   Where caseId=@CaseId and ST.EmployeeId=@ToEmpId     
   --  and  SD.MasterId=@ScheduleId    
     Exec  [dbo].[SP_UpdateScheduleDetailStartandendDate]   @CaseId,@ToEmpId    
    Exec [sp_updateIslockFlag] @CaseId    
    Exec [dbo].[sp_updateEmployeedeptIsLockLogFlag]  @ToEmpId    
      End    
 Commit Transaction    
   End Try    
   Begin Catch    
   Rollback    
   RAISERROR(@ErrMsg,16,1);    
    --Select ERROR_MESSAGE()    
   End Catch    
End 
GO

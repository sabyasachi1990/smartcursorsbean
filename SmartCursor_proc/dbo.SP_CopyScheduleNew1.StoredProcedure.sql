USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CopyScheduleNew1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    --CREATE TYPE [dbo].[TempCopyEmployees] AS TABLE(
    --[FromEmployeeId] uniqueIdentifier NOT NULL,
    --[ToEmployeeId] uniqueIdentifier NOT NULL,
    --[ToEmpStartDate] Datetime NOT NULL)

CREATE Procedure [dbo].[SP_CopyScheduleNew1]       
	@CompanyId BIGINT,      
	@FromCaseId Uniqueidentifier,      
	@ToCaseId Uniqueidentifier,      
	@TempCopyEmployees TempCopyEmployees ReadOnly

AS
BEGIN

	DECLARE @ErrMsg Nvarchar(250),  @EmpName Nvarchar(500)        
      
	DECLARE ----->>> 1st While Loop 
	@FromScheduleDtlId Uniqueidentifier, @ScheduleTaskId Uniqueidentifier,  @ScheduletaskStartdate DateTime2, @ScheduletaskEnddate DateTime2,
	@From_STHours int, @From_IsOvrRunHours int, @IsOverRun Int, @FirstTime Int, 
	@FromScheduleId Uniqueidentifier = (SELECT Id FROM WorkFlow.ScheduleNew (NOLOCK) WHERE CaseId = @FromCaseId),  ----->>> This is Schedule Id Based on FromCaseId , 
	@ScheduleId Uniqueidentifier = (SELECT Id FROM WorkFlow.ScheduleNew (NOLOCK) WHERE CaseId = @ToCaseId),  ----->>> This is Schedule Id Based on ToCaseId ,        
	@Title nvarchar(500), @FirstFromEmpStartDate DateTime2, @FromEmpStartDate Datetime, @FromEmpId uniqueIdentifier, @ToEmpId uniqueIdentifier

	DECLARE ----->>> 2nd While Loop
	@DepartMentId Uniqueidentifier,@DeptDesgId Uniqueidentifier,@LevelRank Int, @ChargeOutRate Nvarchar(50),@SDId_ST Uniqueidentifier,        
	@To_STHours int,@To_STIsOvrRunHours int, @Count Int,@Updt_ST_Hours int,@Updt_ST_IsovrRunHrs int,@TaskFirstDate datetime2,        
	@PreviousTaskDate datetime2,@DayCount int,@ToCaseScheduleDtlId Uniqueidentifier  

BEGIN TRANSACTION
BEGIN TRY 

DECLARE @Table TABLE 
(S_No Int,FromEmpId uniqueidentifier,ToEmpId uniqueidentifier,Id uniqueidentifier,ScheduleDetailId	uniqueidentifier,StartDate	datetime2,EndDate datetime2,PlannedHours int,
 OverRunHours int, IsOverRun	bit,Task	nvarchar(500), CompanyId BigInt
)
 
	DECLARE @WhileTempCopyEmployees  TABLE(S_No int Identity(1,1),[FromEmployeeId] uniqueIdentifier NOT NULL,[ToEmployeeId] uniqueIdentifier NOT NULL,
									   [ToEmpStartDate] Datetime NOT NULL
									  )
	INSERT INTO @WhileTempCopyEmployees
	SELECT * FROM @TempCopyEmployees

	---------================================ 1 ST WHILE ================================--------
	DECLARE @EmployeeCount  Int = (SELECT COUNT(*) FROM @WhileTempCopyEmployees )
	DECLARE @Recount INT = 1

	WHILE  @EmployeeCount >= @Recount
	BEGIN

		SELECT 
		@FromEmpId = [FromEmployeeId], @ToEmpId = [ToEmployeeId],  
		@FirstFromEmpStartDate = [ToEmpStartDate], @FromEmpStartDate = CONVERT(date,[ToEmpStartDate])
		FROM @WhileTempCopyEmployees
		WHERE S_No = @Recount

	  SET @ScheduleId = (SELECT Id From WorkFlow.ScheduleNew WHERE CaseId = @ToCaseId) ----->>> This is Schedule Id Based on  ToCaseId      
	  SET @FromScheduleId = (SELECT Id From WorkFlow.ScheduleNew where CaseId = @FromCaseId) ----->>> This is Schedule Id Based on  FromCaseId      
	  SET @FirstFromEmpStartDate = @FromEmpStartDate ----->>> Get @FirstFromEmpStartDate from  @FromEmpStartDate Parameter      
	  SET @FirstTime=1 ----->>> SET @FirstTime defult 1      
	  SET @FromEmpStartDate = CONVERT(date,@FromEmpStartDate) ----->>> Get @@FromEmpStartDate from  @FromEmpStartDate Parameter and convert date formart      
 
		INSERT INTO @Table
		SELECT ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY convert(date,StartDate) ) AS [S_No],
			@FromEmpId,@ToEmpId,Id,ScheduleDetailId,StartDate,EndDate,PlannedHours,OverrunHours,IsOverRun,Task,CompanyId 
		FROM WorkFlow.ScheduleTaskNew (NOLOCK) 
		WHERE caseId = @FromCaseId AND EmployeeId = @FromEmpId   
		AND ScheduleDetailId IN ( SELECT id FROM  WorkFlow.ScheduleDetailNew WHERE MasterId = @FromScheduleId)  
		ORDER BY StartDate  
		
			-------------================================ 2 ND WHILE ================================--------
			DECLARE @EmployeeCount2  Int = (SELECT COUNT(*) FROM @Table )
			DECLARE @Recount2 INT = 1

			WHILE  @EmployeeCount2 >= @Recount2
			BEGIN

			SELECT 
				@FromEmpId = FromEmpId,@ToEmpId = ToEmpId,@ScheduleTaskId = Id,@FromScheduleDtlId = ScheduleDetailId,@ScheduletaskStartdate = StartDate,
				@ScheduletaskEnddate = EndDate,@From_STHours = PlannedHours,@From_IsOvrRunHours = OverrunHours,@IsOverRun = IsOverRun,@Title = Task--,@FirstTime = 1
				,@CompanyId = CompanyId
			FROM @Table 
			WHERE S_No = @Recount2

					IF(@FirstTime=1)
						BEGIN       
							SET @TaskFirstDate = @ScheduletaskStartdate        
							SET @DayCount = DATEDIFF(dd,@TaskFirstDate,@ScheduletaskStartdate)        
						END 
			
					IF(@FirstTime=0) 
						SET @DayCount = DATEDIFF(dd,@PreviousTaskDate,@ScheduletaskStartdate)   			
						SET @FirstTime=0        
						SET @PreviousTaskDate = @ScheduletaskStartdate        
						SET @FromEmpStartDate = DATEADD(dd,@DayCount,@FirstFromEmpStartDate)         
						SET @ScheduletaskStartdate =  [dbo].[CheckDateAvalibility](@FromEmpStartDate,@ToCaseId,@CompanyId,@ToEmpId)         
						SET @FirstFromEmpStartDate=@ScheduletaskStartdate        
						SET @FromEmpStartDate = DATEADD(dd,1,@ScheduletaskStartdate)           
                              
						SELECT @Count = COUNT(Id) FROM HR.EmployeeDepartment (NOLOCK)     
						WHERE EmployeeId = @ToEmpId AND EffectiveFrom <= @ScheduletaskStartdate AND (@ScheduletaskStartdate <= EffectiveTo  OR EffectiveTo IS NULL)         
             
						  IF @Count <> 0        
						   BEGIN        
							   SELECT @DepartMentId=DepartmentId,@DeptDesgId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate         
							   FROM HR.EmployeeDepartment (NOLOCK)         
							   WHERE EmployeeId=@ToEmpId AND EffectiveFrom <= @ScheduletaskStartdate AND (@ScheduletaskStartdate <= EffectiveTo  OR EffectiveTo IS NULL)         
				
							SET @ToCaseScheduleDtlId = (  SELECT Distinct  SD.Id FROM WorkFlow.ScheduleDetailNew SD (NOLOCK)        
														 INNER JOIN WorkFlow.ScheduleNew S (NOLOCK) ON S.Id=SD.MasterId        
														 WHERE S.CaseId=@ToCaseId AND   EmployeeId=@ToEmpId  AND  MasterId = @ScheduleId        
													   )  			
          
						  IF EXISTS (SELECT * FROM WorkFlow.ScheduleTaskNew (NOLOCK)
									 WHERE EmployeeId=@ToEmpId AND StartDate=@ScheduletaskStartdate         
									  AND Task=@Title AND ScheduleDetailId=@ToCaseScheduleDtlId AND CaseId=@ToCaseId )        
							BEGIN       
							   SELECT @SDId_ST = ScheduleDetailId,@To_STHours = PlannedHours,@To_STIsOvrRunHours=OverRunHours
							   FROM WorkFlow.ScheduleTaskNew  (NOLOCK)
							   WHERE EmployeeId=@ToEmpId AND StartDate=@ScheduletaskStartdate AND Task=@Title AND ScheduleDetailId=@ToCaseScheduleDtlId AND CaseId=@ToCaseId        
               
							   BEGIN      
								 SELECT @EmpName=FirstName FROM Common.Employee WHERE Id=@ToEmpId        
								 SET @ErrMsg = CONCAT(@EmpName,' Hours Exceeded ','On ',CONVERT(date,@ScheduletaskStartdate))        
								 SET @Updt_ST_Hours= ISNULL(@From_STHours,0)+ISNULL(@To_STHours,0)        
							   END
			   
							   SET @Updt_ST_IsovrRunHrs= ISNULL(@From_IsOvrRunHours,0)+ISNULL(@To_STIsOvrRunHours,0)        

									UPDATE WorkFlow.ScheduleTaskNew WITH (ROWLOCK) 
									SET PlannedHours=@Updt_ST_Hours,OverrunHours=@Updt_ST_IsovrRunHrs,        
										ScheduleDetailId=@ToCaseScheduleDtlId,IsOverRun=@IsOverRun,ChargeoutRate=@ChargeOutRate        
									WHERE EmployeeId=@ToEmpId AND  StartDate=@ScheduletaskStartdate  AND Task=@Title AND ScheduleDetailId=@ToCaseScheduleDtlId        
									AND CaseId=@ToCaseId  
							END  
							ELSE             
									INSERT INTO WorkFlow.ScheduleTaskNew        
									(
										Id,CompanyId,CaseId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,StartDate,EndDate,        
										IsOverRun,PlannedHours,OverRunHours,Task,ChargeoutRate,Remarks,Status,Level,WeekNumber
									)        
									SELECT 
										NEWID(),CompanyId,@ToCaseId,@ToCaseScheduleDtlId,@DepartMentId,@DeptDesgId,@ToEmpId,@ScheduletaskStartdate,@ScheduletaskStartdate,        
										@IsOverRun,PlannedHours,OverrunHours,Task,@ChargeOutRate,Remarks,Status,@LevelRank,DATENAME(WW,@ScheduletaskStartdate)        
									FROM WorkFlow.ScheduleTaskNew 
									WHERE Id=@ScheduleTaskId        
						  END    

				SET @Recount2 = @Recount2 + 1
			END		
		
		DELETE FROM @Table
     SET @Recount = @Recount + 1
	END
----=======================================================================================================================================----
	DECLARE  @EmpId1 Nvarchar(max)
	
	SET @EmpId1= (SELECT STRING_AGG(CAST([ToEmployeeId] AS Nvarchar(200)), ', ') AS Employee 
    FROM @TempCopyEmployees)

	BEGIN

		EXEC [dbo].[SP_UpdateScheduleDetailStartandendDate] @ToCaseId, @EmpId1
		EXEC [sp_updateIslockFlag] @ToCaseId
		EXEC [sp_updateIslockFlag] @FromCaseId
		EXEC [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmpId1
	END

COMMIT TRANSACTION
END TRY
	BEGIN CATCH
		ROLLBACK
		RAISERROR(@ErrMsg, 16, 1);
	END CATCH
END
GO

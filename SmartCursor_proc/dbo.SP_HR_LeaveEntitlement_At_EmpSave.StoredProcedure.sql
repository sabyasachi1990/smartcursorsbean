USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_LeaveEntitlement_At_EmpSave]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_HR_LeaveEntitlement_At_EmpSave] (@COMPANYID BIGINT, @EMPID UNIQUEIDENTIFIER, @USERCREATED VARCHAR(100), @EMPSTARTDATE DATETIME2(7), @IdType NVARCHAR(50), @Gender NVARCHAR(50))
AS
BEGIN --m1

--DECLARE
--    @COMPANYID bigint = 2058,
--    @EMPID uniqueidentifier = 'CEBD83B9-7212-4228-9348-0FCEA2D8A1A9',
--    @USERCREATED varchar(100) = 'KHOR BOON HONG',
--    @EMPSTARTDATE datetime2(7) = '2022-12-10 00:00:00.0000000',
--    @IdType nvarchar(50) = 'Passport',
--    @Gender nvarchar(50) = ''

    BEGIN TRANSACTION --m2

    BEGIN TRY --m3
        --Declare @LeaveSetUp_Tbl Table (S_No Int Identity(1,1),DesignationIds Uniqueidentifier)
        DECLARE @EmptyGuid uniqueidentifier = CAST(CAST(0 AS binary) AS uniqueidentifier)


        DECLARE @DEPTID uniqueidentifier,
                @DESGID uniqueidentifier,
                @LEAVETYPEID uniqueidentifier,
                @HrSettingDetailId uniqueidentifier,
                @ACCURALLEAVE int = 0,
                @ACCURALDAYS int = 0,
                @ENTITLEMENT float = 0.0,
                @DIFFMONTH float = 0.0,
                @CARRYFORWARDDAYS float,
                @ACCURALTYPE varchar(100),
                @PRORATED float = 0,
                @TestPRORATED float = 0,
                @FuturePRORATED float = 0,
                @REMAININGPRORATED float = 0,
                @STARTDATE datetime,
                @FutureDATE datetime,
                @MONTHSTARTDATE datetime,
                @OriginalStartDate datetime,
                @RESETDATE datetime,
                @LeaveTypeCreatedDate datetime,
                @YearDate datetime,
                @LMENDDATE datetime,
                @ApplyToAll nvarchar(20),
                @LeaveType nvarchar(100),
				@IsMonthlyProration Bit


        SELECT @LMENDDATE = DATEADD(YEAR, 1, GETDATE());

        SELECT @HrSettingDetailId = HRMD.Id,
               @STARTDATE = HRMD.STARTDATE,
               @RESETDATE = HRMD.ENDDATE
        FROM COMMON.HRSETTINGS AS HRM (NOLOCK)
            JOIN COMMON.HRSETTINGDETAILS AS HRMD (NOLOCK)
                ON HRM.ID = HRMD.MASTERID
        WHERE COMPANYID = @COMPANYID
              AND (CONVERT(date, HRM.RESETLEAVEBALANCEDATE)) = CONVERT(date, HRMD.ENDDATE)

        SET @OriginalStartDate = @STARTDATE;

        SELECT @DEPTID = DEPARTMENTID,
               @DESGID = DEPARTMENTDESIGNATIONID
        FROM HR.EMPLOYEEDEPARTMENT (NOLOCK)
        WHERE EMPLOYEEID = @EMPID
              AND (
                      (
                          (CAST(EFFECTIVEFROM AS date) <= CAST(GETDATE() AS date))
                          OR (CAST(EFFECTIVEFROM AS date) >= CAST(GETDATE() AS date))
                      )
                      AND (
                              CONVERT(date, EFFECTIVETO) >= CONVERT(date, GETDATE())
                              OR EFFECTIVETO IS NULL
                          )
                  );



        DECLARE SP_HR_Setup2EmpCursor CURSOR FOR
        SELECT LT.Id AS LeaveTypeId,
               LT.LeaveAccuralType,
               LTD.Entitlement,
               LTD.CarryForwardDays,
               LT.CreatedDate,
               ISNULL(LT.AccuralDays, 0),
               LT.ApplyToAll,
               LT.Name
        FROM HR.LEAVETYPE AS LT (NOLOCK)
            FULL OUTER JOIN HR.LEAVETYPEDETAILS AS LTD (NOLOCK)
                ON LT.ID = LTD.LEAVETYPEID
        WHERE LT.COMPANYID = @COMPANYID
              AND LT.STATUS = 1
              AND (
                      LT.IsMOM IS NULL
                      OR LT.IsMOM = 0
                  )
              AND (
                      lt.applytoall = 'Selected'
                      OR lt.applytoall = 'All'
                      OR lt.applytoall = 'Rule Based'
                  )
              AND (
                      ISNULL(LTd.DepartmentId, @EmptyGuid) = CASE
                                                                 WHEN Ltd.DepartmentId IS NOT NULL THEN
                                                                     @DeptId
                                                                 ELSE
                                                                     @EmptyGuid
                                                             END
                      AND ISNULL(LTd.DesignationId, @EmptyGuid) = CASE
                                                                      WHEN LTd.DesignationId IS NOT NULL
                                                                           AND LTd.DepartmentId IS NOT NULL THEN
                                                                          @DESGID
                                                                      WHEN LTd.DesignationId IS NOT NULL
                                                                           AND LTd.DepartmentId IS NULL
                                                                           AND
                                                                           (
                                                                               SELECT code
                                                                               FROM [Common].[DepartmentDesignation] (NOLOCK)
                                                                               WHERE id = ltd.DesignationId
                                                                           ) =
                                                                           (
                                                                               SELECT code FROM [Common].[DepartmentDesignation] (NOLOCK) WHERE id = @DESGID
                                                                           ) THEN
                                                                          LTd.DesignationId
                                                                      ELSE
                                                                          @EmptyGuid
                                                                  END
                  )

        --(((LTD.DEPARTMENTID = @DEPTID ) AND (LTD.DESIGNATIONID =   @DESGID OR LTD.DESIGNATIONID IS NULL)) OR (LTD.DEPARTMENTID IS NULL AND LTD.DESIGNATIONID IS NULL))


        OPEN SP_HR_Setup2EmpCursor

        FETCH NEXT FROM SP_HR_Setup2EmpCursor
        INTO @LEAVETYPEID,
             @ACCURALTYPE,
             @ENTITLEMENT,
             @CARRYFORWARDDAYS,
             @LeaveTypeCreatedDate,
             @ACCURALDAYS,
             @ApplyToAll,
             @LeaveType

		WHILE (@@FETCH_STATUS = 0)
		BEGIN --1  
			IF '1' = '1'
			BEGIN --x
				DECLARE @IsInsert BIT=0

				IF (@ApplyToAll = 'Rule Based')
				BEGIN --2
					--print 'yes'
					DECLARE @Condition NVARCHAR(30)
					DECLARE @value NVARCHAR(20)
					DECLARE @Days FLOAT
					DECLARE @LeaveRuleEngineId UNIQUEIDENTIFIER

					SELECT @Condition = [Condition], @value = [Value], @Days = [NoOfDays], @LeaveRuleEngineId = Id
					FROM [HR].[LeaveRuleEngine] (NOLOCK)
					WHERE [LeaveTypeId] = @LEAVETYPEID

					--print @Condition
					--print @value
					--print @LeaveRuleEngineId
					IF (@Condition = 'Date Of Birth' OR @Condition = 'Employment Start Date')
					BEGIN -- 3
						UPDATE [HR].[LeaveRuleEngine]
						SET [EmpCount] = (isnull([EmpCount], 0) + 1)
						WHERE [LeaveTypeId] = @LEAVETYPEID AND id = @LeaveRuleEngineId

						INSERT INTO [HR].[LeaveRuleEngineEmployee] ([Id], [EmployeeId], [LeaveRuleEngineId], [NoOfDays])
						VALUES (newid(), @EMPID, @LeaveRuleEngineId, @Days)

						SET @ENTITLEMENT = @Days
						SET @IsInsert = 1
							--print @ENTITLEMENT
					END --3
					ELSE
					BEGIN --4
						IF (@Condition = @IdType AND @value = @Gender)
						BEGIN --5
							UPDATE [HR].[LeaveRuleEngine]
							SET [EmpCount] = (isnull([EmpCount], 0) + 1)
							WHERE [LeaveTypeId] = @LEAVETYPEID AND id = @LeaveRuleEngineId

							INSERT INTO [HR].[LeaveRuleEngineEmployee] ([Id], [EmployeeId], [LeaveRuleEngineId], [NoOfDays])
							VALUES (newid(), @EMPID, @LeaveRuleEngineId, @Days)

							SET @ENTITLEMENT = @Days
							SET @IsInsert = 1
								--print @ENTITLEMENT
						END --5

						IF (@Condition = @IdType AND @value = 'All')
						BEGIN --6
							UPDATE [HR].[LeaveRuleEngine]
							SET [EmpCount] = (isnull([EmpCount], 0) + 1)
							WHERE [LeaveTypeId] = @LEAVETYPEID AND id = @LeaveRuleEngineId

							INSERT INTO [HR].[LeaveRuleEngineEmployee] ([Id], [EmployeeId], [LeaveRuleEngineId], [NoOfDays])
							VALUES (newid(), @EMPID, @LeaveRuleEngineId, @Days)

							SET @ENTITLEMENT = @Days
							SET @IsInsert = 1
								--print @ENTITLEMENT
						END --6
					END --5
				END --2
				ELSE
				BEGIN
					SET @IsInsert = 1
				END

				IF (@ACCURALTYPE = 'Yearly with proration' AND CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE))
				BEGIN -- 6
					-- for future prorated  
					SET @STARTDATE = CASE WHEN CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @STARTDATE) THEN @STARTDATE ELSE @EMPSTARTDATE END;
					--SET @YearDate =CASE WHEN CONVERT(DATE,@STARTDATE) < CONVERT(DATE,@LeaveTypeCreatedDate)  THEN @LeaveTypeCreatedDate ELSE @STARTDATE END;    
					SET @YearDate = @STARTDATE;
					SET @ACCURALLEAVE = CASE WHEN (DAY(EOMONTH(@YearDate)) - DATEPART(DAY, @YearDate) + 1) >= @ACCURALDAYS THEN 0 ELSE - 1 END;
					SET @DIFFMONTH = (
							SELECT DBO.GETDATEDIFFERENCE(CONVERT(DATE, @YearDate), CONVERT(DATE, @RESETDATE))
							);
					SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
					SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;

					SELECT @PRORATED = value1
					FROM SplitDecimalValue(@TestPRORATED);

					SELECT @FuturePRORATED = @PRORATED;
				END --6
-----------============================================================================================================================================-----
				IF (@ACCURALTYPE = 'Yearly without proration')
				BEGIN --7
					-- for future prorated  
					SELECT @PRORATED = @ENTITLEMENT;

					SELECT @FuturePRORATED = @PRORATED;
				END --7
-----------============================================================================================================================================-----
				IF (@ACCURALTYPE = 'Monthly') 
				 BEGIN
				IF (@ACCURALTYPE = 'Monthly' AND CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE) AND CONVERT(DATE, @EMPSTARTDATE) <= CONVERT(DATE, GETDATE()) )
				BEGIN --8
					SET @STARTDATE = CASE WHEN CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @STARTDATE) THEN @STARTDATE ELSE @EMPSTARTDATE END;
					SET @YearDate = CASE WHEN CONVERT(DATE, @STARTDATE) < CONVERT(DATE, @LeaveTypeCreatedDate) THEN @LeaveTypeCreatedDate ELSE @STARTDATE END;
					SET @ACCURALLEAVE = CASE WHEN (DAY(EOMONTH(@YearDate)) - DATEPART(DAY, @YearDate) + 1) >= @ACCURALDAYS THEN 0 ELSE - 1 END;
					SET @IsMonthlyProration = CASE WHEN (CAST(@EMPSTARTDATE as Date) <= CAST(GETDATE() as Date)) THEN 1 ELSE 0 END;
					--SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))); 

--SELECT @STARTDATE AS Start, @YearDate as Year, @ACCURALLEAVE as AccuralLeaves, @LeaveTypeCreatedDate as LeaveCreated, @ACCURALDAYS as AccuralDays


					if(MONTH(GETDATE())=month(@YearDate) and @ACCURALLEAVE<0 and CONVERT(date,GETDATE())<CONVERT(date,@STARTDATE))
						begin
						set @ACCURALLEAVE=0
						end 


					SET @DIFFMONTH = CASE WHEN CONVERT(DATE, getdate()) < CONVERT(DATE, @YearDate) THEN 0 ELSE (
									SELECT DBO.GETDATEDIFFERENCE(CONVERT(DATE, @YearDate), CONVERT(DATE, GETDATE()))
									) END;
--SELECT @DIFFMONTH AS DiffMonth

					SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
					SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;

--SELECT @TestPRORATED AS TestProRated

					SELECT @PRORATED = value1, @REMAININGPRORATED = value2
					FROM SplitDecimalValue(@TestPRORATED)
--select @PRORATED, @REMAININGPRORATED
					-- for future prorated
					--SET @MONTHSTARTDATE=(SELECT DateAdd(MONTH,1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)));
					SET @DIFFMONTH = (
							SELECT DBO.GETDATEDIFFERENCE(CONVERT(DATE, @YearDate), CONVERT(DATE, @RESETDATE))
							);
					SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
					SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;

					SELECT @FuturePRORATED = value1
					FROM SplitDecimalValue(@TestPRORATED)
				END 
			ELSE
			 IF (@ACCURALTYPE = 'Monthly' AND CONVERT(DATE, @EMPSTARTDATE) > CONVERT(DATE, GETDATE()) AND CONVERT(DATE, @EMPSTARTDATE) < CONVERT(DATE, @RESETDATE))
				BEGIN
				SET @PRORATED = 0
                         SET @TestPRORATED = @ENTITLEMENT - (
																CASE WHEN @EMPSTARTDATE = DATEADD(month, DATEDIFF(month, 0, @EMPSTARTDATE), 0) THEN (@ENTITLEMENT / 12.0) * (DATEDIFF(MM,@STARTDATE, @EMPSTARTDATE))
																	 ELSE (@ENTITLEMENT / 12.0) * (DATEDIFF(MM,@STARTDATE, @EMPSTARTDATE)+1)
																END
															)
                         SELECT @FuturePRORATED = value1
                            FROM SplitDecimalValue(@TestPRORATED)    
				END

		 END--8

--select DATEADD(month, DATEDIFF(month, 0, '2022-12-10'), 0)
--SELECT (20 / 12.0) * (DATEDIFF(MM,'2022-01-01', '2022-11-10')-1)
-------------============================================================================================================================================-----

                IF (@IsInsert = 1)
                BEGIN
                    INSERT INTO HR.LeaveEntitlement
                    (
                        Id,
                        EmployeeId,
                        LeaveTypeId,
                        IsApplicable,
                        AnnualLeaveEntitlement,
                        LeaveApprovers,
                        LeaveRecommenders,
                        Prorated,
                        ApprovedAndTaken,
                        ApprovedAndNotTaken,
                        Remarks,
                        RecOrder,
                        UserCreated,
                        CreatedDate,
                        ModifiedBy,
                        ModifiedDate,
                        Version,
                        STATUS,
                        StartDate,
                        EndDate,
                        BroughtForward,
                        IsEnableLeaveRecommender,
                        Adjustment,
                        Adjusted,
                        CompletedMonth,
                        RemainingProrated,
                        [Current],
                        LeaveBalance,
                        Total,
                        CarryForwardDays,
                        Entitlementstatus,
                        FutureProrated,
                        YTDLeaveBalance,
                        HrSettingDetaiId,
						IsMonthlyProration
                    )
                    VALUES
                    (
					--SELECT
					NEWID(),
                     @EMPID,
                     @LEAVETYPEID,
                     1  ,
                     @ENTITLEMENT,
                     '[]',
                     '[]',
                     @PRORATED ,
                     0  ,
                     0  ,
                     NULL,
                     1  ,
                     'System',
                     GETDATE(),
                     NULL,
                     NULL,
                     2  ,
                     1  ,
                     GETDATE(),
                     @LMENDDATE,
                     0  ,
                     0  ,
                     NULL,
                     NULL,
                     (DATEPART(m, GETDATE())),
                     @REMAININGPRORATED,
                     @PRORATED ,
                     @PRORATED ,
                     @ENTITLEMENT,
                     @CARRYFORWARDDAYS,
                     1  ,
                     @FuturePRORATED,
                     @FuturePRORATED,
                     @HrSettingDetailId,
					 @IsMonthlyProration
                    )
	--END
 ----=========================================================== ANNUAL LEAVE ==========================================================-----

                    IF (@LeaveType = 'Annual Leave')
                    BEGIN --a
                        IF (@ACCURALTYPE = 'Monthly')
                        BEGIN --b
                            

                            UPDATE Common.Employee
                            SET AnnualPTDBalance = @PRORATED,
                                AnnualYTDBalance = @FuturePRORATED
                            WHERE id = @EMPID

							--SELECT  @PRORATED AS AnnualPTDBalance,@FuturePRORATED AS AnnualYTDBalance
                        END --B

                ---=======================================================================================================-----
                        ELSE
                        BEGIN --c

                            SET @STARTDATE = CASE
                                                 WHEN CONVERT(date, @EMPSTARTDATE) < CONVERT(date, @STARTDATE) THEN
                                                     @STARTDATE
                                                 ELSE
                                                     @EMPSTARTDATE
                                             END;
                            SET @YearDate
                                = CASE
                                      WHEN CONVERT(date, @STARTDATE) < CONVERT(date, @LeaveTypeCreatedDate) THEN
                                          @LeaveTypeCreatedDate
                                      ELSE
                                          @STARTDATE
                                  END;
                            SET @ACCURALLEAVE
                                = CASE
                                      WHEN (DAY(EOMONTH(@YearDate)) - DATEPART(DAY, @YearDate) + 1) >= @ACCURALDAYS THEN
                                          0
                                      ELSE
                                          -1
                                  END;
                            --SET @DIFFMONTH =(SELECT DBO.GETDATEDIFFERENCE (CONVERT(DATE,@YearDate),CONVERT(DATE,GETDATE()))); 

                            IF (
                                   MONTH(GETDATE()) = MONTH(@YearDate)
                                   AND @ACCURALLEAVE < 0
                                   AND CONVERT(date, GETDATE()) < CONVERT(date, @STARTDATE)
                               )
                            BEGIN
                                SET @ACCURALLEAVE = 0
                            END




                            SET @DIFFMONTH
                                = CASE
                                      WHEN CONVERT(date, GETDATE()) < CONVERT(date, @YearDate) THEN
                                          0
                                      ELSE
                                  (
                                      SELECT DBO.GETDATEDIFFERENCE(CONVERT(date, @YearDate), CONVERT(date, GETDATE()))
                                  )
                                  END;


                            SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
                           -- SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;
							SET @TestPRORATED = @ENTITLEMENT

              --              SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
              --              SET @TestPRORATED =  (CASE
														----WHEN @ACCURALTYPE = 'Monthly' THEN @ENTITLEMENT3
														----WHEN @ACCURALTYPE = 'Yearly with proration' THEN @ENTITLEMENT2
														--ELSE @ENTITLEMENT
												  --END);


                            SELECT @PRORATED = value1,
                                   @REMAININGPRORATED = value2
                            FROM SplitDecimalValue(@TestPRORATED)

                            -- FOR FUTURE PRORATED
                            --SET @MONTHSTARTDATE=(SELECT DateAdd(MONTH,1,DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)));

                            SET @DIFFMONTH =
                            (
                                SELECT DBO.GETDATEDIFFERENCE(CONVERT(date, @YearDate), CONVERT(date, @RESETDATE))
                            );
 


                            SET @DIFFMONTH = @DIFFMONTH + (@ACCURALLEAVE);
							SET @TestPRORATED = (@DIFFMONTH * @ENTITLEMENT) / 12.0;
             --               SET @TestPRORATED = (CASE
													--	WHEN @ACCURALTYPE = 'Monthly' THEN @ENTITLEMENT3
													--	--WHEN @ACCURALTYPE = 'Yearly with proration' THEN @ENTITLEMENT2
													--	ELSE @ENTITLEMENT
													--END);

                            SELECT @FuturePRORATED = value1
                            FROM SplitDecimalValue(@TestPRORATED)


                            UPDATE Common.Employee
                            SET AnnualPTDBalance = @PRORATED,
                                AnnualYTDBalance = @FuturePRORATED
                            WHERE id = @EMPID

							--SELECT  @PRORATED AS AnnualPTDBalance,@FuturePRORATED AS AnnualYTDBalance
                        END --c
                    END --a
----=====================================================================================================================-----



                    SET @STARTDATE = @OriginalStartDate;
                END
            END --x

            FETCH NEXT FROM SP_HR_Setup2EmpCursor
            INTO @LEAVETYPEID,
                 @ACCURALTYPE,
                 @ENTITLEMENT,
                 @CARRYFORWARDDAYS,
                 @LeaveTypeCreatedDate,
                 @ACCURALDAYS,
                 @ApplyToAll,
                 @LeaveType
        END --1

        CLOSE SP_HR_Setup2EmpCursor

        DEALLOCATE SP_HR_Setup2EmpCursor

        COMMIT TRANSACTION --m2
    END TRY --m3

    BEGIN CATCH
        ROLLBACK TRANSACTION

        DECLARE @ErrorMessage nvarchar(4000) --, @ErrorSeverity INT, @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

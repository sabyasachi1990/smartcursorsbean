USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ClaimsEntitlement_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_ClaimsEntitlement_HR] (@category_Name NVARCHAR(50), @company_Id BIGINT, @apply_To NVARCHAR(50), @type NVARCHAR(50))
AS
BEGIN
	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--SET @company_Id = 1077
	DECLARE @HrSettingDetailId UNIQUEIDENTIFIER

	CREATE TABLE #AllEmployee_Tbl (S_No INT Identity(1, 1), EntitlementId UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, EntitlementDetailId UNIQUEIDENTIFIER, ClaimItemId UNIQUEIDENTIFIER, CompanyId BIGINT, DepartmentId UNIQUEIDENTIFIER, DesignationId UNIQUEIDENTIFIER)

	CREATE TABLE #DesignationIds (S_No INT Identity(1, 1), DesignationId UNIQUEIDENTIFIER, Code NVARCHAR(500))

	CREATE TABLE #Category_Tbl (S_No INT Identity(1, 1), ClaimItemId UNIQUEIDENTIFIER, ClaimSetuiId UNIQUEIDENTIFIER, Category NVARCHAR(200), CategoryLimit MONEY NULL, AnnualLimit MONEY NULL, TransactionLimit MONEY NULL, ApplyTo NVARCHAR(200), DepartmentId UNIQUEIDENTIFIER NULL, DesignationId UNIQUEIDENTIFIER NULL, Type_1 NVARCHAR(200), CompanyId BIGINT, UserCreated NVARCHAR(500))

	BEGIN TRANSACTION --1

	BEGIN TRY --2
		INSERT INTO #Category_Tbl
		SELECT DISTINCT CI.ID, CS.Id, CS.[Category], CS.[CategoryLimit], CSD.[AnnualLimit], CSD.[TransactionLimit], CS.[ApplyTo], CS.[DepartmentId], CS.[DesignationId], CS.Type, CS.Companyid, CI.[UserCreated]
		FROM [HR].[ClaimSetup] CS
		INNER JOIN [HR].[ClaimItem] CI ON CS.[CompanyId] = CI.[CompanyId]
		INNER JOIN [HR].[ClaimSetupDetail] CSD ON CI.[Id] = CSD.[ClaimItemId]
		WHERE CS.STATUS = 1 AND CI.STATUS = 1 AND CS.ID = CSD.[ClaimSetupId] AND CS.CompanyId = @company_Id AND CI.CompanyId = @company_Id AND CS.[Category] = @category_Name

		--SELECT *FROM #Category_Tbl
		PRINT 'Claims'

		SET @HrSettingDetailId = (
				SELECT TOP (1) hrd.Id
				FROM Common.HRSettingdetails AS HRD
				INNER JOIN Common.HRSettings AS HS ON HS.Id = HRD.MasterId
				WHERE HS.CompanyId = @company_Id
				ORDER BY StartDate DESC
				)

		PRINT @HrSettingDetailId

		INSERT INTO HR.EmployeeClaimsEntitlement (Id, CompanyId, EmployeeId, STATUS, CreatedDate)
		SELECT NEWID(), @company_Id, EMP.Id, 1, GETDATE()
		FROM Common.Employee AS EMP
		LEFT JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.EmployeeId = Emp.Id
		WHERE Emp.CompanyId = @company_Id AND IdType IS NOT NULL AND ECE.Id IS NULL

		INSERT INTO #AllEmployee_Tbl
		SELECT DISTINCT HCE.Id, HCE.[EmployeeId], HCED.Id, HCED.[ClaimItemId], CE.Companyid, CE.[DepartmentId], CE.[DesignationId]
		FROM [HR].[EmployeeClaimsEntitlement] HCE
		INNER JOIN Common.Employee CE ON HCE.[EmployeeId] = CE.Id AND CE.CompanyId = @company_Id AND ce.Idtype IS NOT NULL AND ce.STATUS = 1
		INNER JOIN (
			SELECT DISTINCT ClaimItemId AS Id, CompanyId
			FROM #Category_Tbl
			) AS item ON item.CompanyId = CE.CompanyId
		LEFT JOIN [HR].[EmployeeClaimsEntitlementDetail] HCED ON HCE.Id = HCED.[EmployeeClaimsEntitlementId] AND HCE.CompanyId = @company_Id AND HCED.[HrSettingDetaiId] = @HrSettingDetailId AND HCED.[ClaimItemId] = item.Id

		--pRINT 'entitlement'
		IF (@apply_To = 'All')
		BEGIN --3	
			--declare @TotalCount int =(select count(*) from #Category_Tbl)
			--declare @RecCount int  = 1
			--WHILE @CompanyCount >= @RecCount
			--BEGIN --1
			--==============================================================
			--INSERT INTO #AllEmployee_Tbl SELECT DISTINCT HCE.Id, HCE.[EmployeeId], HCED.Id, HCED.[ClaimItemId], CE.Companyid, CE.[DepartmentId], CE.[DesignationId] FROM [HR].[EmployeeClaimsEntitlement] HCE JOIN Common.Employee CE ON HCE.[EmployeeId] = CE.Id AND CE.CompanyId = @company_Id AND ce.Idtype IS NOT NULL JOIN (SELECT DISTINCT ClaimItemId AS Id, CompanyId FROM #Category_Tbl) AS item ON item.CompanyId = CE.CompanyId LEFT JOIN [HR].[EmployeeClaimsEntitlementDetail] HCED ON HCE.Id = HCED.[EmployeeClaimsEntitlementId] AND HCE.CompanyId = @company_Id AND HCED.[HrSettingDetaiId] = @HrSettingDetailId AND HCED.[ClaimItemId] = item.Id
			--==============================================================
			--PRINT 'employees'
			--DECLARE @count INT = (SELECT count(*) FROM #AllEmployee_Tbl WHERE EntitlementDetailId IS NULL)
			--PRINT @count			PRINT 'employees count'
			--DECLARE @count1 UNIQUEIDENTIFIER = (
			--		SELECT DISTINCT ClaimItemId
			--		FROM #Category_Tbl
			--		)
			--PRINT @count1
			--SELECT * FROM #AllEmployee_Tbl
			IF EXISTS (
					SELECT *
					FROM #AllEmployee_Tbl
					WHERE EntitlementDetailId IS NULL
					)
			BEGIN --4
				PRINT '1'

				IF EXISTS (
						SELECT *
						FROM #AllEmployee_Tbl
						WHERE EntitlementDetailId IS NOT NULL
						)
				BEGIN --1
					DECLARE @CategoryCount INT = (
							SELECT count(*)
							FROM #Category_Tbl
							)
					DECLARE @CategoryReCount INT = 1
					DECLARE @TransactionLimt1 MONEY
					DECLARE @AnnualLimt1 MONEY
					DECLARE @CategoryLimt1 MONEY
					DECLARE @claimitemId1 UNIQUEIDENTIFIER
					DECLARE @username1 NVARCHAR(500)

					WHILE @CategoryCount >= @CategoryReCount
					BEGIN --new 
						SELECT @CategoryLimt1 = CategoryLimit, @AnnualLimt1 = AnnualLimit, @TransactionLimt1 = TransactionLimit, @claimitemId1 = ClaimItemId, @username1 = UserCreated
						FROM #Category_Tbl
						WHERE S_No = @CategoryReCount

						DECLARE @entitlementId4 UNIQUEIDENTIFIER

						DECLARE Employee_Cursor CURSOR
						FOR
						SELECT DISTINCT EntitlementId
						FROM #AllEmployee_Tbl
						WHERE EntitlementDetailId IS NULL

						OPEN Employee_Cursor

						FETCH NEXT
						FROM Employee_Cursor
						INTO @entitlementId4

						WHILE @@FETCH_STATUS = 0
						BEGIN --new
							IF NOT EXISTS (
									SELECT EntitlementId
									FROM #AllEmployee_Tbl
									WHERE EntitlementDetailId IS NOT NULL AND ClaimItemId = @claimitemId1 AND EntitlementId = @entitlementId4
									)
							BEGIN --23
								INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
								SELECT newid(), @entitlementId4, @claimitemId1, 1, @type, @TransactionLimt1, @AnnualLimt1, year(getutcdate()), @CategoryLimt1, getutcdate(), @username1, @HrSettingDetailId
							END --23

							FETCH NEXT
							FROM Employee_Cursor
							INTO @entitlementId4
						END --new 

						CLOSE Employee_Cursor

						DEALLOCATE Employee_Cursor

						SET @CategoryReCount = @CategoryReCount + 1
					END --new
				END --1
				ELSE
				BEGIN --2
					INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
					SELECT newid(), a.EntitlementId, c.ClaimItemId, 1, c.Type_1, c.TransactionLimit, c.AnnualLimit, year(getutcdate()), c.CategoryLimit, getdate(), c.UserCreated, @HrSettingDetailId
					FROM #AllEmployee_Tbl a
					INNER JOIN #Category_Tbl c ON a.Companyid = c.Companyid
					WHERE a.EntitlementDetailId IS NULL AND c.ClaimItemId NOT IN (
							SELECT DISTINCT ClaimItemId
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NOT NULL
							)
				END --2
			END --4

			IF EXISTS (
					SELECT *
					FROM #AllEmployee_Tbl
					WHERE EntitlementDetailId IS NOT NULL
					)
			BEGIN --5
				PRINT '2'

				UPDATE ECE
				SET ECE.TransactionLimit = csd.TransactionLimit, ECE.AnnualLimit = csd.AnnualLimit, ECE.CategoryLimit = cs.CategoryLimit
				FROM hr.EmployeeClaimsEntitlementDetail AS ECE
				INNER JOIN hr.claimitem ci ON ci.Id = ECE.ClaimItemId
				INNER JOIN hr.claimSetupDetail csd ON ci.Id = csd.claimItemId
				INNER JOIN hr.claimSetup cs ON csd.claimSetupId = cs.Id AND CS.CompanyId = Ci.CompanyId
				WHERE ci.CompanyId = @company_Id AND cs.type = @type AND cs.ApplyTo = @apply_To AND cs.IsFromClaimItem = 0 AND ci.type = @type AND ECE.HrSettingDetaiId = @HrSettingDetailId AND ECE.[Id] IN (
						SELECT EntitlementDetailId
						FROM #AllEmployee_Tbl
						WHERE EntitlementDetailId IS NOT NULL
						)

				--================ To update the Bal amounts =================	
				--UPDATE ECE
				--SET ECE.TransactionLimit = csd.TransactionLimit, ECE.AnnualLimit = csd.AnnualLimit, ECE.CategoryLimit = cs.CategoryLimit
				--FROM hr.EmployeeClaimsEntitlementDetail AS ECE
				--INNER JOIN hr.claimitem ci ON ci.Id = ECE.ClaimItemId
				--JOIN hr.claimSetupDetail csd ON ci.Id = csd.claimItemId
				--JOIN hr.claimSetup cs ON csd.claimSetupId = cs.Id AND CS.CompanyId = Ci.CompanyId
				--WHERE ci.CompanyId = @company_Id AND cs.type = @type AND cs.ApplyTo = @apply_To AND cs.IsFromClaimItem = 0 AND ci.type = @type AND ECE.HrSettingDetaiId = @HrSettingDetailId
				--================ To update the Bal amounts =================	
				UPDATE E
				SET E.RemainingAmount = A.ItemLevelBal, E.CategoryBalanceAmount = A.CategoryBal
				FROM hr.EmployeeClaimsEntitlementDetail E
				INNER JOIN (
					SELECT ECED.Id AS Id, ECED.[ClaimItemId], (CASE WHEN ECED.AnnualLimit IS NOT NULL THEN (ECED.AnnualLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE (CASE WHEN ECED.TransactionLimit IS NOT NULL THEN (ECED.TransactionLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE NULL END) END) AS ItemLevelBal, (CASE WHEN ECED.CategoryLimit IS NOT NULL THEN ISNULL(ECED.CategoryLimit, 0) - (ISNULL(ECED.CategoryUtilizedAmount, 0) + ISNULL(ECED.CategoryPreApprovedAmount, 0)) ELSE NULL END) AS CategoryBal
					FROM (
						SELECT EmployeeId AS EmployeeId, EntitlementId AS EmployeeClaimsEntitlementId, CompanyId, EntitlementDetailId AS DetailId
						FROM #AllEmployee_Tbl
						WHERE EntitlementDetailId IS NOT NULL
						) AS EMP1
					INNER JOIN HR.EmployeeClaimsEntitlementDetail AS ECED ON ECED.EmployeeClaimsEntitlementId = EMP1.EmployeeClaimsEntitlementId AND ECED.Id = DetailId
					WHERE
						--and ECED.EmployeeClaimsEntitlementId = @claimsEntitlement_id
						ECED.HrSettingDetaiId = @HrSettingDetailId AND ECED.STATUS = 1
					) A ON A.Id = E.Id AND E.HrSettingDetaiId = @HrSettingDetailId AND A.Id = E.Id
			END --5
		END --3
		ELSE
		BEGIN ---6
			DECLARE @TotalCount INT = (
					SELECT count(*)
					FROM #Category_Tbl
					)
			DECLARE @count1 INT = 1

			WHILE @TotalCount >= @count1
			BEGIN --7
				PRINT 'loop count ' + CAST(@count1 AS NVARCHAR(50))

				DECLARE @department_Id UNIQUEIDENTIFIER
				DECLARE @designation_Id UNIQUEIDENTIFIER
				DECLARE @TransactionLimt MONEY
				DECLARE @AnnualLimt MONEY
				DECLARE @CategoryLimt MONEY
				DECLARE @claimitemId UNIQUEIDENTIFIER
				DECLARE @username NVARCHAR(500)

				SELECT @department_Id = DepartmentId, @designation_Id = DesignationId, @CategoryLimt = CategoryLimit, @AnnualLimt = AnnualLimit, @TransactionLimt = TransactionLimit, @claimitemId = ClaimItemId, @username = UserCreated
				FROM #Category_Tbl
				WHERE S_No = @count1

				--declare dummyid uniqueidentifier =isnull(@designation_Id,(SELECT CAST(0x0 AS UNIQUEIDENTIFIER)))
				--print 'departmentid '+CAST(@department_Id as NVARCHAR(50)) +'designationid'+CAST(@designation_Id as NVARCHAR(50))
				--PRINT @designation_Id				PRINT @department_Id
				IF (
						@department_Id IS NOT NULL AND @designation_Id IS NOT NULL AND @department_Id != (
							SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
							) AND @designation_Id != (
							SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
							)
						)
				BEGIN --8
					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id
							)
					BEGIN --9
						--PRINT 'Department is not null and DesignationId is not null'
						--DECLARE @count3 INT = (SELECT count(*) FROM #AllEmployee_Tbl WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id)
						--PRINT @count3
						IF NOT EXISTS (
								SELECT TOP 1 EntitlementId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id AND ClaimItemId = @claimitemId
								)
						BEGIN --21
							INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
							SELECT newid(), a.EntitlementId, c.ClaimItemId, 1, c.Type_1, c.TransactionLimit, c.AnnualLimit, year(getutcdate()), c.CategoryLimit, getutcdate(), c.UserCreated, @HrSettingDetailId
							FROM #AllEmployee_Tbl a
							INNER JOIN #Category_Tbl c ON a.Companyid = c.Companyid
							WHERE a.EntitlementDetailId IS NULL AND c.ClaimItemId NOT IN (
									SELECT DISTINCT ClaimItemId
									FROM #AllEmployee_Tbl
									WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id
									) AND a.DepartmentId = @department_Id AND a.DesignationId = @designation_Id AND c.DepartmentId = @department_Id AND c.DesignationId = @designation_Id AND c.ClaimItemId = @claimitemId
						END --21
						ELSE
						BEGIN --22
							DECLARE @entitlementId UNIQUEIDENTIFIER

							DECLARE Employee_Cursor CURSOR
							FOR
							SELECT DISTINCT EntitlementId
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id

							OPEN Employee_Cursor

							FETCH NEXT
							FROM Employee_Cursor
							INTO @entitlementId

							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF NOT EXISTS (
										SELECT EntitlementId
										FROM #AllEmployee_Tbl
										WHERE EntitlementDetailId IS NOT NULL AND ClaimItemId = @claimitemId AND EntitlementId = @entitlementId
										)
								BEGIN --23
									INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
									SELECT newid(), @entitlementId, @claimitemId, 1, @type, @TransactionLimt, @AnnualLimt, year(getutcdate()), @CategoryLimt, getutcdate(), @username, @HrSettingDetailId
								END --23

								FETCH NEXT
								FROM Employee_Cursor
								INTO @entitlementId
							END

							CLOSE Employee_Cursor

							DEALLOCATE Employee_Cursor
						END --22
					END --9

					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id AND ClaimItemId = @claimitemId
							)
					BEGIN --10
						UPDATE ECE
						SET ECE.TransactionLimit = @TransactionLimt, ECE.AnnualLimit = @AnnualLimt, ECE.CategoryLimit = @CategoryLimt
						FROM hr.EmployeeClaimsEntitlementDetail AS ECE
						WHERE ECE.HrSettingDetaiId = @HrSettingDetailId AND ECE.[Id] IN (
								SELECT EntitlementDetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id
								) AND ECE.[ClaimItemId] = @claimitemId

						UPDATE E
						SET E.RemainingAmount = A.ItemLevelBal, E.CategoryBalanceAmount = A.CategoryBal
						FROM hr.EmployeeClaimsEntitlementDetail E
						INNER JOIN (
							SELECT ECED.Id AS Id, ECED.[ClaimItemId], (CASE WHEN ECED.AnnualLimit IS NOT NULL THEN (ECED.AnnualLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE (CASE WHEN ECED.TransactionLimit IS NOT NULL THEN (ECED.TransactionLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE NULL END) END) AS ItemLevelBal, (CASE WHEN ECED.CategoryLimit IS NOT NULL THEN ISNULL(ECED.CategoryLimit, 0) - (ISNULL(ECED.CategoryUtilizedAmount, 0) + ISNULL(ECED.CategoryPreApprovedAmount, 0)) ELSE NULL END) AS CategoryBal
							FROM (
								SELECT EmployeeId AS EmployeeId, EntitlementId AS EmployeeClaimsEntitlementId, CompanyId, EntitlementDetailId AS DetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id
								) AS EMP1
							INNER JOIN HR.EmployeeClaimsEntitlementDetail AS ECED ON ECED.EmployeeClaimsEntitlementId = EMP1.EmployeeClaimsEntitlementId AND ECED.Id = DetailId
							WHERE
								--and ECED.EmployeeClaimsEntitlementId = @claimsEntitlement_id
								ECED.HrSettingDetaiId = @HrSettingDetailId AND ECED.STATUS = 1 AND ECED.[ClaimItemId] = @claimitemId
							) A ON A.Id = E.Id AND E.HrSettingDetaiId = @HrSettingDetailId AND A.Id = E.Id
					END --10
				END --8
				ELSE IF (
						(
							@department_Id IS NOT NULL AND @department_Id != (
								SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
								)
							) AND (
							@designation_Id IS NULL OR @designation_Id = (
								SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
								)
							)
						)
				BEGIN --12
					PRINT 'Department is not null and DesignationId is  null'

					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id
							)
					BEGIN --13
						--PRINT '1'
						--declare @count2 int=(SELECT count(*) FROM #AllEmployee_Tbl WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id AND DesignationId = @designation_Id)
						--print @count2
						PRINT 'Department is not null and DesignationId is  null'

						IF NOT EXISTS (
								SELECT *
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND ClaimItemId = @claimitemId
								)
						BEGIN --21
							INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
							SELECT newid(), a.EntitlementId, c.ClaimItemId, 1, c.Type_1, c.TransactionLimit, c.AnnualLimit, year(getutcdate()), c.CategoryLimit, getdate(), c.UserCreated, @HrSettingDetailId
							FROM #AllEmployee_Tbl a
							INNER JOIN #Category_Tbl c ON a.Companyid = c.Companyid
							WHERE a.EntitlementDetailId IS NULL AND c.ClaimItemId NOT IN (
									SELECT DISTINCT ClaimItemId
									FROM #AllEmployee_Tbl
									WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id
									) AND a.DepartmentId = @department_Id AND c.DepartmentId = @department_Id AND c.ClaimItemId = @claimitemId
						END --21
						ELSE
						BEGIN --22
							DECLARE @entitlementId1 UNIQUEIDENTIFIER

							DECLARE Employee_Cursor CURSOR
							FOR
							SELECT DISTINCT EntitlementId
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DepartmentId = @department_Id

							OPEN Employee_Cursor

							FETCH NEXT
							FROM Employee_Cursor
							INTO @entitlementId1

							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF NOT EXISTS (
										SELECT EntitlementId
										FROM #AllEmployee_Tbl
										WHERE EntitlementDetailId IS NOT NULL AND ClaimItemId = @claimitemId AND EntitlementId = @entitlementId1
										)
								BEGIN --23
									INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
									SELECT newid(), @entitlementId1, @claimitemId, 1, @type, @TransactionLimt, @AnnualLimt, year(getutcdate()), @CategoryLimt, getutcdate(), @username, @HrSettingDetailId
								END --23

								FETCH NEXT
								FROM Employee_Cursor
								INTO @entitlementId1
							END

							CLOSE Employee_Cursor

							DEALLOCATE Employee_Cursor
						END --22
					END --13

					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id AND ClaimItemId = @claimitemId
							)
					BEGIN --14
						UPDATE ECE
						SET ECE.TransactionLimit = @TransactionLimt, ECE.AnnualLimit = @AnnualLimt, ECE.CategoryLimit = @CategoryLimt
						FROM hr.EmployeeClaimsEntitlementDetail AS ECE
						WHERE ECE.HrSettingDetaiId = @HrSettingDetailId AND ECE.[Id] IN (
								SELECT EntitlementDetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id
								) AND ECE.[ClaimItemId] = @claimitemId

						UPDATE E
						SET E.RemainingAmount = A.ItemLevelBal, E.CategoryBalanceAmount = A.CategoryBal
						FROM hr.EmployeeClaimsEntitlementDetail E
						INNER JOIN (
							SELECT ECED.Id AS Id, ECED.[ClaimItemId], (CASE WHEN ECED.AnnualLimit IS NOT NULL THEN (ECED.AnnualLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE (CASE WHEN ECED.TransactionLimit IS NOT NULL THEN (ECED.TransactionLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE NULL END) END) AS ItemLevelBal, (CASE WHEN ECED.CategoryLimit IS NOT NULL THEN ISNULL(ECED.CategoryLimit, 0) - (ISNULL(ECED.CategoryUtilizedAmount, 0) + ISNULL(ECED.CategoryPreApprovedAmount, 0)) ELSE NULL END) AS CategoryBal
							FROM (
								SELECT EmployeeId AS EmployeeId, EntitlementId AS EmployeeClaimsEntitlementId, CompanyId, EntitlementDetailId AS DetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DepartmentId = @department_Id
								) AS EMP1
							INNER JOIN HR.EmployeeClaimsEntitlementDetail AS ECED ON ECED.EmployeeClaimsEntitlementId = EMP1.EmployeeClaimsEntitlementId AND ECED.Id = DetailId
							WHERE
								--and ECED.EmployeeClaimsEntitlementId = @claimsEntitlement_id
								ECED.HrSettingDetaiId = @HrSettingDetailId AND ECED.STATUS = 1 AND ECED.[ClaimItemId] = @claimitemId
							) A ON A.Id = E.Id AND E.HrSettingDetaiId = @HrSettingDetailId AND A.Id = E.Id
					END --14
				END --12
				ELSE IF (
						(
							@department_Id IS NULL OR @department_Id = (
								SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
								)
							) AND (
							@designation_Id IS NOT NULL AND @designation_Id != (
								SELECT CAST(0x0 AS UNIQUEIDENTIFIER)
								)
							)
						)
				BEGIN --15
					INSERT INTO #DesignationIds
					SELECT DISTINCT dd.Id, dd.code
					FROM [Common].[Department] d
					INNER JOIN [Common].[DepartmentDesignation] dd ON d.id = dd.[DepartmentId]
					WHERE d.[CompanyId] = @company_Id AND dd.code = (
							SELECT code
							FROM common.DepartmentDesignation
							WHERE Id = @designation_Id
							)

					PRINT 'Department is  null and DesignationId is not null'

					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DesignationId IN (
									SELECT DesignationId
									FROM #DesignationIds
									)
							)
					BEGIN --16
						--PRINT '1'
						PRINT 'Department is  null and DesignationId is not null'

						IF NOT EXISTS (
								SELECT *
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DesignationId IN (
										SELECT DesignationId
										FROM #DesignationIds
										) AND ClaimItemId = @claimitemId
								)
						BEGIN --21
							INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
							SELECT newid(), a.EntitlementId, c.ClaimItemId, 1, c.Type_1, c.TransactionLimit, c.AnnualLimit, year(getutcdate()), c.CategoryLimit, getdate(), c.UserCreated, @HrSettingDetailId
							FROM #AllEmployee_Tbl a
							INNER JOIN #Category_Tbl c ON a.Companyid = c.Companyid
							WHERE a.EntitlementDetailId IS NULL AND c.ClaimItemId NOT IN (
									SELECT DISTINCT ClaimItemId
									FROM #AllEmployee_Tbl
									WHERE EntitlementDetailId IS NOT NULL AND DesignationId = @designation_Id
									) /*AND a.DepartmentId = @department_Id */ AND a.DesignationId IN (
									SELECT DesignationId
									FROM #DesignationIds
									) AND c.DesignationId IN (
									SELECT DesignationId
									FROM #DesignationIds
									) AND c.ClaimItemId = @claimitemId
						END --21
						ELSE
						BEGIN --22
							DECLARE @entitlementId2 UNIQUEIDENTIFIER

							DECLARE Employee_Cursor CURSOR
							FOR
							SELECT DISTINCT EntitlementId
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NULL AND DesignationId IN (
									SELECT DesignationId
									FROM #DesignationIds
									)

							OPEN Employee_Cursor

							FETCH NEXT
							FROM Employee_Cursor
							INTO @entitlementId2

							WHILE @@FETCH_STATUS = 0
							BEGIN
								IF NOT EXISTS (
										SELECT EntitlementId
										FROM #AllEmployee_Tbl
										WHERE EntitlementDetailId IS NOT NULL AND ClaimItemId = @claimitemId AND EntitlementId = @entitlementId2
										)
								BEGIN --23
									INSERT INTO hr.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, ClaimItemId, STATUS, ClaimType, TransactionLimit, AnnualLimit, Year, CategoryLimit, CreatedDate, UserCreated, HrSettingDetaiId)
									SELECT newid(), @entitlementId2, @claimitemId, 1, @type, @TransactionLimt, @AnnualLimt, year(getutcdate()), @CategoryLimt, getutcdate(), @username, @HrSettingDetailId
								END --23

								FETCH NEXT
								FROM Employee_Cursor
								INTO @entitlementId2
							END

							CLOSE Employee_Cursor

							DEALLOCATE Employee_Cursor
						END --22
					END --16

					IF EXISTS (
							SELECT *
							FROM #AllEmployee_Tbl
							WHERE EntitlementDetailId IS NOT NULL AND DesignationId IN (
									SELECT DesignationId
									FROM #DesignationIds
									) AND ClaimItemId = @claimitemId
							)
					BEGIN --17
						UPDATE ECE
						SET ECE.TransactionLimit = @TransactionLimt, ECE.AnnualLimit = @AnnualLimt, ECE.CategoryLimit = @CategoryLimt
						FROM hr.EmployeeClaimsEntitlementDetail AS ECE
						WHERE ECE.HrSettingDetaiId = @HrSettingDetailId AND ECE.[Id] IN (
								SELECT EntitlementDetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DesignationId IN (
										SELECT DesignationId
										FROM #DesignationIds
										)
								) AND ECE.[ClaimItemId] = @claimitemId

						UPDATE E
						SET E.RemainingAmount = A.ItemLevelBal, E.CategoryBalanceAmount = A.CategoryBal
						FROM hr.EmployeeClaimsEntitlementDetail E
						INNER JOIN (
							SELECT ECED.Id AS Id, ECED.[ClaimItemId], (CASE WHEN ECED.AnnualLimit IS NOT NULL THEN (ECED.AnnualLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE (CASE WHEN ECED.TransactionLimit IS NOT NULL THEN (ECED.TransactionLimit - (ISNULL(ECED.UtilizedAmount, 0) + ISNULL(ECED.SubmittedAmount, 0))) ELSE NULL END) END) AS ItemLevelBal, (CASE WHEN ECED.CategoryLimit IS NOT NULL THEN ISNULL(ECED.CategoryLimit, 0) - (ISNULL(ECED.CategoryUtilizedAmount, 0) + ISNULL(ECED.CategoryPreApprovedAmount, 0)) ELSE NULL END) AS CategoryBal
							FROM (
								SELECT EmployeeId AS EmployeeId, EntitlementId AS EmployeeClaimsEntitlementId, CompanyId, EntitlementDetailId AS DetailId
								FROM #AllEmployee_Tbl
								WHERE EntitlementDetailId IS NOT NULL AND DesignationId IN (
										SELECT DesignationId
										FROM #DesignationIds
										)
								) AS EMP1
							INNER JOIN HR.EmployeeClaimsEntitlementDetail AS ECED ON ECED.EmployeeClaimsEntitlementId = EMP1.EmployeeClaimsEntitlementId AND ECED.Id = DetailId
							WHERE
								--and ECED.EmployeeClaimsEntitlementId = @claimsEntitlement_id
								ECED.HrSettingDetaiId = @HrSettingDetailId AND ECED.STATUS = 1 AND ECED.[ClaimItemId] = @claimitemId
							) A ON A.Id = E.Id AND E.HrSettingDetaiId = @HrSettingDetailId AND A.Id = E.Id
					END --17

					TRUNCATE TABLE #DesignationIds
				END --15

				SET @count1 = @count1 + 1
			END --7
		END --6

		IF OBJECT_ID(N'tempdb..#AllEmployee_Tbl') IS NOT NULL
		BEGIN
			DROP TABLE #AllEmployee_Tbl
		END

		IF OBJECT_ID(N'tempdb..#Category_Tbl') IS NOT NULL
		BEGIN
			DROP TABLE #Category_Tbl
		END

		IF OBJECT_ID(N'tempdb..#DesignationIds') IS NOT NULL
		BEGIN
			DROP TABLE #DesignationIds
		END

		COMMIT TRANSACTION --1
	END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO

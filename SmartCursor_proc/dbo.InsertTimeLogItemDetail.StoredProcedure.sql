USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[InsertTimeLogItemDetail]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertTimeLogItemDetail] --- EXEC [dbo].[InsertTimeLogItemDetail]

AS
BEGIN

	DECLARE @Temporary TABLE (Id BigInt Identity(1,1), CaseId Uniqueidentifier,EmployeeId Uniqueidentifier,CompanyId Bigint)

	INSERT INTO @Temporary
	SELECT A.CaseId,A.EmployeeId,A.CompanyId
	FROM
	(
		SELECT CaseId,B.EmployeeId,A.CompanyId
		FROM Workflow.Schedulenew A 
		JOIN Workflow.ScheduleDetailNew B 
		ON A.Id = B.MasterId 							
	) A  
	LEFT JOIN
		(
			SELECT SystemId,EmployeeId 
			FROM Common.TimeLogItem A 
			JOIN Common.TimeLogItemDetail B 
			ON A.Id = B.TimeLogItemId 
			WHERE A.SystemType = 'CaseGroup' 
		) B
	ON A.CaseId = B.SystemId AND B.EmployeeId = A.EmployeeId
	JOIN Common.Employee C ON A.EmployeeId = C.Id
	WHERE B.SystemId IS NULL AND B.EmployeeId IS NULL

	--------============================================ CURSOR =====================================================-----
	BEGIN
	DECLARE @CNT Int
	SET @CNT = (SELECT COUNT(*) FROM @Temporary)

	IF (@CNT > 0)
	BEGIN

	DECLARE @caseId uniqueidentifier, @employeeId uniqueidentifier, @TimelogItemId Uniqueidentifier

	DECLARE scheduleDetail CURSOR FOR

	SELECT CaseId,EmployeeId 
	FROM @Temporary

	OPEN scheduleDetail 

	FETCH NEXT FROM scheduleDetail into @caseId,@employeeId

		 WHILE @@FETCH_STATUS = 0
		  BEGIN

			SET @TimelogItemId = (SELECT Id FROM Common.TimeLogItem  WHERE SystemId = @caseId AND SystemType = 'CaseGroup')

			 INSERT INTO Common.TimeLogItemDetail ([Id],[TimeLogItemId],[EmployeeId])
				SELECT NEWID(),@TimelogItemId,@employeeId

		   FETCH NEXT FROM scheduleDetail into @caseId,@employeeId
		 END
		 CLOSE scheduleDetail
		 DEALLOCATE scheduleDetail

	END
	END	

END


----============================================== OLD
----BEGIN
----DECLARE @CNT Int
----SET @CNT = (SELECT COUNT(*) FROM VW_TimelogItemdetailMissing)

----IF (@CNT > 0)
----BEGIN
----DECLARE @caseId uniqueidentifier, @employeeId uniqueidentifier, @TimelogItemId Uniqueidentifier
----DECLARE scheduleDetail CURSOR FOR (SELECT CaseId,EmployeeId FROM VW_TimelogItemdetailMissing)
----     OPEN scheduleDetail 
----     FETCH NEXT FROM scheduleDetail into @caseId,@employeeId
----     WHILE @@FETCH_STATUS = 0
----      BEGIN
----		SET @TimelogItemId = (SELECT Id FROM Common.TimeLogItem WHERE SystemId = @caseId AND SystemType = 'CaseGroup')

----		INSERT INTO Common.TimeLogItemDetail ([Id],[TimeLogItemId],[EmployeeId])
----			SELECT NEWID(),@TimelogItemId,@employeeId

----	   FETCH NEXT FROM scheduleDetail into @caseId,@employeeId
----	 End
----	 Close scheduleDetail
----	 Deallocate scheduleDetail
----END
----END


----============================================== WHILE LOOP
--DECLARE @Temporary TABLE (Id BigInt Identity(1,1), CaseId Uniqueidentifier,EmployeeId Uniqueidentifier,CompanyId Bigint)


--INSERT INTO @Temporary
--SELECT A.CaseId,A.EmployeeId,A.CompanyId
--FROM
--(
--	SELECT CaseId,B.EmployeeId,A.CompanyId
--	FROM Workflow.Schedulenew A (NOLOCK)
--	JOIN Workflow.ScheduleDetailNew B (NOLOCK)
--	ON A.Id = B.MasterId 							

--) A  
--LEFT JOIN
--	(
--		SELECT SystemId,EmployeeId 
--		FROM Common.TimeLogItem A (NOLOCK)
--		JOIN Common.TimeLogItemDetail B (NOLOCK)
--		ON A.Id = B.TimeLogItemId 
--		WHERE A.SystemType = 'CaseGroup' 
--	) B
--ON
--	A.CaseId = B.SystemId AND B.EmployeeId = A.EmployeeId
--JOIN
--	Common.Employee C ON A.EmployeeId = C.Id
--WHERE
--		B.SystemId IS NULL AND B.EmployeeId IS NULL

--------=================================================================================================-----
--DECLARE @caseId uniqueidentifier, @EmployeeId uniqueidentifier, @TimelogItemId Uniqueidentifier

--DECLARE @Count  Int = (SELECT COUNT(*) FROM @Temporary )
--DECLARE @Recount INT = 1


--WHILE  @Count >= @Recount
--BEGIN

--	SELECT @Caseid = CaseId, @EmployeeId = EmployeeId FROM @Temporary WHERE Id = @Recount

--	SET @TimelogItemId = (SELECT Id FROM Common.TimeLogItem (NOLOCK) WHERE SystemId = @caseId AND SystemType = 'CaseGroup')

--	INSERT INTO Common.TimeLogItemDetail ([Id],[TimeLogItemId],[EmployeeId])
--	SELECT NEWID(),@TimelogItemId,@EmployeeId
	
--	SET @Recount = @Recount + 1
--END
GO

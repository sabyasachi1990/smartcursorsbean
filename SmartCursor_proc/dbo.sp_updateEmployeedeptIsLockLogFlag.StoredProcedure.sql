USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_updateEmployeedeptIsLockLogFlag]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---->> EXEC  [dbo].[sp_updateEmployeedeptIsLockLogFlag] 'd7d52662-dea5-4f98-9aea-8d3d3ec63299,CC51AC0E-6226-4965-A22F-40FFC6F43D43'   
--========================================================================06 ==================================================================  
CREATE PROCEDURE [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmployeeId nvarchar(max)
AS
BEGIN

----->> DECLARE @EmployeeId nvarchar(max)  =  'd7d52662-dea5-4f98-9aea-8d3d3ec63299,CC51AC0E-6226-4965-A22F-40FFC6F43D43'   
 
DECLARE @EmpId uniqueidentifier, @DepartmentId uniqueidentifier, @DesignationId uniqueidentifier, @Level int, @ChargeOutRate nvarchar(512)

DECLARE @WhileLoop TABLE (S_No Int Identity(1,1),EmpId uniqueidentifier, DepartmentId uniqueidentifier, DesignationId uniqueidentifier,Level int, ChargeOutRate nvarchar(512))

INSERT INTO @WhileLoop
SELECT DISTINCT EmployeeId, DepartmentId, DepartmentDesignationId,ISNULL(LevelRank, 0) LevelRank, ISNULL(ChargeOutRate, 0) AS ChargeOutRate
FROM HR.EmployeeDepartment (NOLOCK)
WHERE EmployeeId IN ( SELECT LTRIM(items) AS Items FROM SplitToTable(@EmployeeId, ','))
ORDER BY EmployeeId

---->> SELECT * FROM @WhileLoop
    
DECLARE @EmployeeCount  Int = (SELECT COUNT(*) FROM @WhileLoop )
DECLARE @Recount INT = 1

---->>SELECT  @EmployeeCount, @Recount

WHILE  @EmployeeCount >= @Recount
BEGIN

---->> SELECT @Recount as recount

	SELECT @EmpId = EmpId, @DepartmentId = DepartmentId, @DesignationId = DesignationId, @Level = Level, @ChargeOutRate = ChargeOutRate
	FROM @WhileLoop WHERE S_No = @Recount

	----->>> SELECT @EmpId , @DepartmentId , @DesignationId , @Level , @ChargeOutRate 
        
        IF EXISTS ------======================= Checking employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
        (SELECT DISTINCT TOP 1 EmployeeId FROM WorkFlow.ScheduleDetailNew (NOLOCK)
            WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
                  AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))

            UNION ALL

            SELECT DISTINCT TOP 1  EmployeeId FROM WorkFlow.ScheduleTaskNew (NOLOCK)
            WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
                  AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))

            UNION ALL

            SELECT DISTINCT TOP 1  TL.Id FROM Common.TimeLog AS TL (NOLOCK)
                INNER JOIN Common.TimeLogItem AS TLI (NOLOCK) ON TLI.Id = TL.TimeLogItemId
                INNER JOIN Common.TimeLogDetail T (NOLOCK) ON T.MasterId = tl.Id
            WHERE (TLI.SystemId IS NOT NULL OR TLI.SystemId IS NULL )
                  AND TL.EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
                  AND T.Duration <> '00:00:00.0000000' AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))
        )
        BEGIN

 -------======================================= update IsLocked=1 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
			------SELECT  1  FROM HR.EmployeeDepartment (NOLOCK)
			------WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
			------AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate
            
			UPDATE HR.EmployeeDepartment WITH (ROWLOCK) SET IsLocked = 1
			WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
			AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate
        END
        ELSE
        BEGIN
-------======================================= update IsLocked=0 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
			------SELECT  0  FROM HR.EmployeeDepartment (NOLOCK)
			------WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
			------AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate

			UPDATE HR.EmployeeDepartment WITH (ROWLOCK) SET IsLocked = 0
			WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
			AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate
        END

   SET @Recount = @Recount +1
END

END




--------================================================================ OLD QUERY ================================================================-------
    ----DECLARE @EmpId uniqueidentifier, @DepartmentId uniqueidentifier, @DesignationId uniqueidentifier,
    ----        @Level int, @ChargeOutRate nvarchar(512)

    ----DECLARE EmployeedeptIsLock_Csr CURSOR FOR  
    ----SELECT DISTINCT EmployeeId, DepartmentId, DepartmentDesignationId,ISNULL(LevelRank, 0) LevelRank, ISNULL(ChargeOutRate, 0) AS ChargeOutRate
    ----FROM HR.EmployeeDepartment (NOLOCK)
    ----WHERE EmployeeId IN ( SELECT items FROM SplitToTable(@EmployeeId, ','))
    ----ORDER BY EmployeeId
    
    ----OPEN EmployeedeptIsLock_Csr
    ----FETCH NEXT FROM EmployeedeptIsLock_Csr INTO @EmpId, @DepartmentId, @DesignationId, @Level, @ChargeOutRate
    ----WHILE @@FETCH_STATUS = 0
    ----BEGIN
        
    ----    IF EXISTS ------======================= Checking employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
    ----    (SELECT DISTINCT EmployeeId
    ----        FROM WorkFlow.ScheduleDetailNew (NOLOCK)
    ----        WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
    ----              AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))

    ----        UNION ALL

    ----        SELECT DISTINCT EmployeeId
    ----        FROM WorkFlow.ScheduleTaskNew (NOLOCK)
    ----        WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
    ----              AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))

    ----        UNION ALL

    ----        SELECT DISTINCT TL.Id
    ----        FROM Common.TimeLog AS TL (NOLOCK)
    ----            INNER JOIN Common.TimeLogItem AS TLI (NOLOCK) ON TLI.Id = TL.TimeLogItemId
    ----            INNER JOIN Common.TimeLogDetail T (NOLOCK) ON T.MasterId = tl.Id
    ----        WHERE (TLI.SystemId IS NOT NULL OR TLI.SystemId IS NULL )
    ----              AND TL.EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DesignationId = @DesignationId
    ----              AND T.Duration <> '00:00:00.0000000' AND ISNULL(level, 0) = @level AND ISNULL(ChargeoutRate, 0) = CAST(@ChargeOutRate AS decimal(28, 9))
    ----    )
    ----    BEGIN
    ----        -------======================================= update IsLocked=1 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
    ----        UPDATE HR.EmployeeDepartment SET IsLocked = 1
    ----        WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
    ----              AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate
    ----    END
    ----    ELSE
    ----    BEGIN
    ----        -------======================================= update IsLocked=0 employeeId,DepartmentId,DepartmentDesignationId,LevelRank, ChargeOutRate  
    ----        UPDATE HR.EmployeeDepartment SET IsLocked = 0
    ----        WHERE EmployeeId = @EmpId AND DepartmentId = @DepartmentId AND DepartmentDesignationId = @DesignationId
    ----              AND ISNULL(LevelRank, 0) = @level AND ISNULL(ChargeoutRate, 0) = @ChargeOutRate
    ----    END


    ----    FETCH NEXT FROM EmployeedeptIsLock_Csr INTO @EmpId, @DepartmentId, @DesignationId, @Level, @ChargeOutRate
    ----END


    ----CLOSE EmployeedeptIsLock_Csr
    ----DEALLOCATE EmployeedeptIsLock_Csr
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF2TimelogUpdation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[WF2TimelogUpdation]
@LeaveApplicationIds NVARCHAR(MAX)

AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
 
        DECLARE @IdTable AS TABLE (GuidValue UNIQUEIDENTIFIER);
        INSERT INTO @IdTable (GuidValue)
        SELECT CONVERT(UNIQUEIDENTIFIER, value)
        FROM STRING_SPLIT(LTRIM(RTRIM(@LeaveApplicationIds)), ',')

        UPDATE TI
        SET TI.SystemSubTypeStatus = LA.LeaveStatus
        FROM Common.TimeLogItem AS TI
        INNER JOIN HR.LeaveApplication AS LA ON TI.SystemId = LA.Id
        WHERE TI.SystemId IN (SELECT GuidValue FROM @IdTable);

 
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK; 
        PRINT 'In Catch Block';
        THROW;
    END CATCH
END;
GO

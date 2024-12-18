USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[InsertTimeLogItem]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertTimeLogItem] 
AS
BEGIN

DECLARE 
	 @CaseId Uniqueidentifier, @caseName Nvarchar(1000),@caseNumber Nvarchar(2000),@userCreated Nvarchar(500),@createdDate DateTime2(7),@companyId Bigint,
	 @startDate Datetime2(7),@endDate Datetime2(7)
 
      DECLARE @Count int = 1, @MaxCount int
 
      DECLARE @CaseTable TABLE (SerailId Int Identity(1,1), CaseId Uniqueidentifier)
 
     INSERT INTO @CaseTable
    SELECT Id FROM WorkFlow.CaseGroup as a  
    WHERE NOT EXISTS (SELECT SystemId FROM Common.TimeLogItem as b WHERE SystemType='CaseGroup' and b.SystemId = a.id )
 
  SELECT @MaxCount = COUNT(*) FROM @CaseTable
  PRINT @MaxCount
 
WHILE @Count <= @MaxCount
BEGIN
	SELECT @CaseId = CaseId  FROM @CaseTable WHERE SerailId = @Count
 
	DECLARE @TLIId Uniqueidentifier = NewId()
	INSERT INTO Common.TimeLogItem ([Id],[CompanyId],[Type],[SubType],[ChargeType],[SystemType],[SystemId],[IsSystem],[ApplytoAll],[UserCreated],[CreatedDate],[Status],[Hours],[Days],[StartDate],[EndDate])
		SELECT
			@TLIId,CompanyId,CaseNumber,Name,'Chargeable','CaseGroup',@caseId,1,0,UserCreated,CreatedDate,1,0.00,0.00,
			ScheduleStartDate,ScheduleEndDate
		FROM Workflow.CaseGroup AS A (NOLOCK) 
		WHERE Id = @CaseId
 
	INSERT INTO Common.TimeLogItemDetail ([Id],[TimeLogItemId],[EmployeeId])
		SELECT NEWID(),@TLIId, sd.EmployeeId FROM 
		WorkFlow.ScheduleNew AS s (NOLOCK) 
		INNER JOIN WorkFlow.ScheduleDetailNew AS sd (NOLOCK)  ON s.id=sd.MasterId 
		WHERE s.CaseId = @CaseId
 
		SET @Count = @Count+1
		
END
END

GO

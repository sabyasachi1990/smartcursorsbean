USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WorkProfile]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [AppsWorldInt]
--GO
--/****** Object:  StoredProcedure [dbo].[SP_WorkProfile]    Script Date: 01/08/2017 1:15:42 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROCEDURE [dbo].[SP_WorkProfile](@CompanyId bigint, @WORKPROFILEID UNIQUEIDENTIFIER)
AS
BEGIN
	DECLARE @T TABLE (
		Id uniqueidentifier ,
		CompanyId bigint ,
		WorkProfileName nvarchar(50) ,
		WorkingHoursPerDay float ,
		Monday nvarchar(5) ,
		Tuesday nvarchar(5) ,
		Wednenday nvarchar(5) ,
		Thursday nvarchar(5) ,
		Friday nvarchar(5) ,
		Saturday nvarchar(5) ,
		Sunday nvarchar(5) ,
		TotalWorkingDaysPerWeek float ,
		TotalWorkingHoursPerWeek float ,
		IsDefaultProfile bit ,
		IsSuperUserRec bit ,
		Remarks nvarchar(256) ,
		UserCreated nvarchar(50) ,
		CreatedDate datetime2(7) ,
		ModifiedDate datetime2(7) ,
		ModifiedBy nvarchar(50) ,
		RecOrder int ,
		Status int ,
		Version smallint);

	DECLARE @WorkProfileName NVARCHAR(20) = (SELECT WORKPROFILENAME FROM HR.WorkProfile WHERE ID=@WORKPROFILEID)
	DECLARE @NWPD UNIQUEIDENTIFIER;

	
	IF EXISTS(SELECT WORKPROFILENAME FROM HR.WorkProfile WHERE CompanyId=@CompanyId AND WorkProfileName=@WorkProfileName)
	
	BEGIN
		INSERT INTO @T
		SELECT * FROM hr.WorkProfile where Id=@WORKPROFILEID
		SELECT @NWPD = ID FROM hr.WorkProfile where WorkProfileName=@WorkProfileName and companyId = @CompanyId

		UPDATE HR.WorkProfile SET 
			[WorkProfileName]=(select [WorkProfileName] from @T),
			[WorkingHoursPerDay]=(select [WorkingHoursPerDay] from @T),
			[Monday]=(select Monday from @T),
			[Tuesday]=(select Tuesday from @T),
			[Wednenday]=(select Wednenday from @T),
			[Thursday]=(select Thursday from @T),
			[Friday]=(select Friday from @T),
			[Saturday]=(select Saturday from @T),
			[Sunday]=(select Sunday from @T),
			[TotalWorkingDaysPerWeek]=(select TotalWorkingDaysPerWeek from @T),
			[TotalWorkingHoursPerWeek]=(select TotalWorkingHoursPerWeek from @T),
			--[IsDefaultProfile]=(select IsDefaultProfile from @T),
			[IsSuperUserRec]=1,
			[Remarks]=(select Remarks from @T),
			[UserCreated]=(select UserCreated from @T),
			[CreatedDate]=(select CreatedDate from @T),
			[ModifiedDate]=(select ModifiedDate from @T),
			[ModifiedBy]=(select ModifiedBy from @T),
			[RecOrder]=(select RecOrder from @T),
			[Status]=(select Status from @T),
			[Version]=(select Version from @T) where WorkProfileName=@WorkProfileName and companyId = @CompanyId

		UPDATE [HR].[WorkProfileDetails] SET 
			--[HR].[WorkProfileDetails].Year = WD.Year,
			--[HR].[WorkProfileDetails].MasterId = WD.MasterId,
			[HR].[WorkProfileDetails].JanuaryDays = WD.JanuaryDays,
			[HR].[WorkProfileDetails].FebruaryDays = WD.FebruaryDays, 
			[HR].[WorkProfileDetails].MarchDays = WD.MarchDays,
			[HR].[WorkProfileDetails].AprilDays = WD.AprilDays,
			[HR].[WorkProfileDetails].MayDays = WD.MayDays, 
			[HR].[WorkProfileDetails].JuneDays = WD.JuneDays, 
			[HR].[WorkProfileDetails].JulyDays = WD.JulyDays, 
			[HR].[WorkProfileDetails].AugustDays = WD.AugustDays, 
			[HR].[WorkProfileDetails].SeptemberDays = WD.SeptemberDays, 
			[HR].[WorkProfileDetails].OctoberDays = WD.OctoberDays, 
			[HR].[WorkProfileDetails].NovemberDays = WD.NovemberDays, 
			[HR].[WorkProfileDetails].DecemberDays = WD.DecemberDays, 
			[HR].[WorkProfileDetails].TotalWorkingHoursPerYear = WD.TotalWorkingHoursPerYear, 
			[HR].[WorkProfileDetails].TotalWorkingDaysPerYear = WD.TotalWorkingDaysPerYear, 
			[HR].[WorkProfileDetails].Remarks = WD.Remarks, 
			[HR].[WorkProfileDetails].UserCreated = WD.UserCreated, 
			[HR].[WorkProfileDetails].CreatedDate = WD.CreatedDate, 
			[HR].[WorkProfileDetails].ModifiedDate = WD.ModifiedDate, 
			[HR].[WorkProfileDetails].ModifiedBy = WD.ModifiedBy, 
			[HR].[WorkProfileDetails].RecOrder = WD.RecOrder, 
			[HR].[WorkProfileDetails].Status = WD.Status, 
			[HR].[WorkProfileDetails].Version= WD.Version
			FROM
			(
				SELECT WD.* FROM
				[HR].[WorkProfileDetails] WD 
				INNER JOIN [HR].[WorkProfileDetails] NWD ON WD.Year = NWD.Year
				WHERE WD.MASTERID=@WORKPROFILEID AND NWD.MASTERID=@NWPD
			) WD
			WHERE [HR].[WorkProfileDetails].Year = Wd.Year AND [HR].[WorkProfileDetails].MASTERID=@NWPD
			--[HR].[WorkProfileDetails].Id = (SELECT ID FROM HR.WorkProfileDetails WHERE MASTERID=@NWPD AND YEAR = WD.Year)
			
			
			-----------Inserting the WorkProfileDeatils which are not present in the company @companyId-------------------------------------------------------------

			INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
			SELECT NEWID(), 
			(SELECT Id FROM HR.WorkProfile WHERE CompanyId=@CompanyId AND WorkProfileName = @WorkProfileName) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear, WD.Remarks, WD.UserCreated, WD.CreatedDate, WD.ModifiedDate, WD.ModifiedBy, WD.RecOrder, WD.Status, WD.Version 
			--select wd.*
			FROM
			(
				SELECT WD.*
				FROM [HR].[WorkProfileDetails] WD WHERE WD.MASTERID=@WORKPROFILEID and year not in (SELECT NWD.year
				FROM [HR].[WorkProfileDetails] NWD WHERE NWD.MASTERID=@NWPD) 
			) as WD

			--#region Comment
				--(
				--SELECT WD.* FROM
				--[HR].[WorkProfileDetails] WD 
				--INNER JOIN [HR].[WorkProfileDetails] NWD ON WD.Year <> NWD.Year   ---------We have problem here (if years are different int compId=0 & different onse), We nneed to solve that
				--WHERE WD.MASTERID=@WORKPROFILEID AND NWD.MASTERID=@NWPD
				--  ) WD
				--  WHERE [HR].[WorkProfileDetails].Year = Wd.Year AND [HR].[WorkProfileDetails].MASTERID=@WORKPROFILEID

		
				--DELETE FROM HR.WorkProfileDetails where MasterId= (SELECT ID FROM HR.WorkProfile WHERE CompanyId=@CompanyId AND WorkProfileName=@WorkProfileName)

				--INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
				--SELECT NEWID(), (SELECT Id FROM HR.WorkProfile WHERE CompanyId=@CompanyId AND WorkProfileName = (select WorkProfileName FROM [HR].[WorkProfile] where Id = WD.MasterId and CompanyId = @CompanyId)) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear, WD.Remarks, WD.UserCreated, WD.CreatedDate, WD.ModifiedDate, WD.ModifiedBy, WD.RecOrder, WD.Status, WD.Version 
				--FROM [HR].[WorkProfileDetails] WD INNER JOIN [HR].[WorkProfile] W
				--ON W.Id = WD.MasterId
				--WHERE W.COMPANYID = 0
				--#endregion

	END

	ELSE

	BEGIN

		----------------------Inserting the WorkProfile & WorkProfileDetails-NEW Records-------------------------------------------------------------------------

		INSERT INTO HR.WorkProfile (Id, CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, IsSuperUserRec, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
		SELECT NEWID(), @CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, 1 , Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version 
		FROM HR.WorkProfile WHERE CompanyId=0 and WorkProfileName=@WorkProfileName

		INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
		SELECT NEWID(), (SELECT Id FROM HR.WorkProfile WHERE CompanyId=@CompanyId AND WorkProfileName = (select WorkProfileName FROM [HR].[WorkProfile] where Id = WD.MasterId and CompanyId = 0)) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear, WD.Remarks, WD.UserCreated, WD.CreatedDate, WD.ModifiedDate, WD.ModifiedBy, WD.RecOrder, WD.Status, WD.Version 
		FROM [HR].[WorkProfileDetails] WD INNER JOIN [HR].[WorkProfile] W
		ON W.Id = WD.MasterId
		WHERE W.COMPANYID = 0 and w.WorkProfileName=@WorkProfileName

	END

  END
GO

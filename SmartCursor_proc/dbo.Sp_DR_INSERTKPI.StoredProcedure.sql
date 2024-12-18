USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_DR_INSERTKPI]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Sp_DR_INSERTKPI]
@CompanyId BIGINT
AS
BEGIN
    INSERT INTO DR.KPITarget (Id, CompanyId, TargetType, TargetName, TargetSymbol, Target, Status, CreatedDate, UserCreated, ModifiedBy, ModifiedDate, RecOrder,FairStartValue,FairEndValue)
    SELECT Newid(),
           @CompanyId,
           TargetType,
           TargetName,
           TargetSymbol,
           Target,
           Status,
           GETDATE(),
           UserCreated,
           NULL,
           NULL,
           RecOrder,
		   FairStartValue,
		   FairEndValue
    FROM   Dr.KPITarget
    WHERE  CompanyId = 0;
END

GO

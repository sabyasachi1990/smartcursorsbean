USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[TempAppraisers]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[TempAppraisers] AS TABLE(
	[AppraiserIds] [nvarchar](max) NOT NULL,
	[AppraiseeId] [uniqueidentifier] NOT NULL,
	[IsSelfAppraiser] [bit] NOT NULL,
	[AppraiserRecordStatus] [nvarchar](25) NOT NULL
)
GO

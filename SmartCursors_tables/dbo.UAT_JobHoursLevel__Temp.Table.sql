USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[UAT_JobHoursLevel__Temp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UAT_JobHoursLevel__Temp](
	[JobTypeId] [uniqueidentifier] NULL,
	[Hours] [decimal](10, 2) NULL,
	[Level] [nvarchar](2) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL
) ON [PRIMARY]
GO

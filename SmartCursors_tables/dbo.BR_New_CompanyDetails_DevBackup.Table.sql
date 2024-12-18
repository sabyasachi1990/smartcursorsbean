USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[BR_New_CompanyDetails_DevBackup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BR_New_CompanyDetails_DevBackup](
	[Date (If takeover)] [datetime] NULL,
	[Source (New/ Takeover)] [nvarchar](255) NULL,
	[Company No#] [nvarchar](255) NULL,
	[Entity Name] [nvarchar](255) NULL,
	[Suffix] [nvarchar](255) NULL,
	[Jurisdiction] [nvarchar](255) NULL,
	[Incorporation_Date (DD/MM/YYYY)] [datetime] NULL,
	[Entity Type] [nvarchar](255) NULL,
	[Company Type] [nvarchar](255) NULL,
	[Last FYE] [datetime] NULL,
	[Last FYE1] [datetime] NULL,
	[First AGM (Yes/ No)] [nvarchar](255) NULL,
	[Last AGM] [datetime] NULL,
	[Last AR] [datetime] NULL,
	[Current FYE (date & month)] [datetime] NULL,
	[Current FYE (Year)] [float] NULL,
	[Local Address/ Foreign Address] [nvarchar](255) NULL,
	[Address Type] [nvarchar](255) NULL,
	[Block/House No] [nvarchar](255) NULL,
	[Street] [nvarchar](255) NULL,
	[Level & Unit no] [nvarchar](255) NULL,
	[Building] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[Postal Code] [float] NULL,
	[Auditor] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Identification No] [nvarchar](255) NULL,
	[Auditor Appt Date] [datetime] NULL,
	[Auditor Local Address/ Foreign Address] [nvarchar](255) NULL,
	[Auditor  Address Type] [nvarchar](255) NULL,
	[Auditor  Block/House No] [nvarchar](255) NULL,
	[Auditor  Street] [datetime] NULL,
	[Auditor Level & Unit no] [datetime] NULL,
	[Auditor Building] [nvarchar](250) NULL,
	[Auditor Country] [nvarchar](255) NULL,
	[Auditor Postal Code] [float] NULL,
	[SSIC_1] [float] NULL,
	[Primary Activity] [nvarchar](255) NULL,
	[Additional Description] [nvarchar](350) NULL,
	[SSIC_2] [float] NULL,
	[Secondary Activity] [nvarchar](255) NULL,
	[Additional Description1] [nvarchar](255) NULL,
	[Position] [nvarchar](300) NULL
) ON [PRIMARY]
GO

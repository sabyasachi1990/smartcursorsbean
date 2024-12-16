USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[CCusers]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCusers](
	[CompanyuserId] [bigint] NOT NULL,
	[Cursorname] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FirstName] [nvarchar](128) NULL,
	[Username] [nvarchar](254) NOT NULL,
	[Status] [varchar](8) NOT NULL
) ON [PRIMARY]
GO

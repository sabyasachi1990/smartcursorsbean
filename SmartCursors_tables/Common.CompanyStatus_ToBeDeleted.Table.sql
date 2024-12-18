USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyStatus_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyStatus_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityName] [nvarchar](250) NULL,
	[StatusChangedDate] [datetime2](7) NULL,
	[FromStatus] [nvarchar](50) NULL,
	[ToStatus] [nvarchar](50) NULL,
	[Remarks] [nvarchar](1000) NULL
) ON [PRIMARY]
GO

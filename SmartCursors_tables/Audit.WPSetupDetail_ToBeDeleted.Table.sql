USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[WPSetupDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[WPSetupDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[WPSetupId] [uniqueidentifier] NOT NULL,
	[WPTypes] [nvarchar](50) NULL,
	[IsTips] [bit] NULL,
	[TipDescription] [nvarchar](max) NULL,
	[IsIncludeExcel] [bit] NULL,
	[IsImport] [bit] NULL,
	[IsGenerate] [bit] NULL,
 CONSTRAINT [PK_WPSetupCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[WPSetupDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_WPSetupCategory_WPSetup] FOREIGN KEY([WPSetupId])
REFERENCES [Audit].[WPSetup] ([Id])
GO
ALTER TABLE [Audit].[WPSetupDetail_ToBeDeleted] CHECK CONSTRAINT [FK_WPSetupCategory_WPSetup]
GO

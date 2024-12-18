USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[WPImportFile_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[WPImportFile_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[WPCategoryId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](50) NULL,
	[FilePath] [nvarchar](100) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_WPImportFile] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[WPImportFile_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[WPImportFile_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_WPImportFile_WPCategory] FOREIGN KEY([WPCategoryId])
REFERENCES [Audit].[WPSetupDetail_ToBeDeleted] ([Id])
GO
ALTER TABLE [Audit].[WPImportFile_ToBeDeleted] CHECK CONSTRAINT [FK_WPImportFile_WPCategory]
GO

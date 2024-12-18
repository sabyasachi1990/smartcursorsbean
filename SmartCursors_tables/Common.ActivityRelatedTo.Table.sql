USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ActivityRelatedTo]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ActivityRelatedTo](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[TableName] [nvarchar](50) NULL,
	[Status] [int] NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[MasterTable] [nvarchar](200) NULL,
	[MasterId] [nvarchar](200) NULL,
	[RecordName] [nvarchar](200) NULL,
	[IsCompanyId] [bit] NULL,
	[Isfolder] [bit] NULL,
	[IsSystem] [bit] NULL,
 CONSTRAINT [PK_ActivityRelatedTo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ActivityRelatedTo]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRelatedTo_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Common].[ActivityRelatedTo] CHECK CONSTRAINT [FK_ActivityRelatedTo_ModuleDetail]
GO
ALTER TABLE [Common].[ActivityRelatedTo]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRelatedTo_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[ActivityRelatedTo] CHECK CONSTRAINT [FK_ActivityRelatedTo_ModuleMaster]
GO

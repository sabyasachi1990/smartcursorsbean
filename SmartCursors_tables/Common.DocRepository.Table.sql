USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DocRepository]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DocRepository](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](200) NULL,
	[TypeKey] [nvarchar](50) NULL,
	[ModuleName] [nvarchar](50) NULL,
	[FilePath] [nvarchar](max) NULL,
	[DisplayFileName] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[FileSize] [decimal](17, 2) NULL,
	[FileExt] [nvarchar](7) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[NameofApprovalAuthority] [nvarchar](100) NULL,
	[TypeIntId] [bigint] NULL,
	[Status] [int] NULL,
	[ShortName] [nvarchar](20) NULL,
	[WordFile] [nvarchar](500) NULL,
	[MongoFilesId] [nvarchar](50) NULL,
	[GroupTypeId] [uniqueidentifier] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[AzurePath] [nvarchar](max) NULL,
	[ScreenName] [nvarchar](100) NULL,
	[AzureFileName] [nvarchar](400) NULL,
	[Date] [datetime2](7) NULL,
 CONSTRAINT [PK_DOCRepository] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[DocRepository] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[DocRepository]  WITH CHECK ADD  CONSTRAINT [FK_DOCRepository_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[DocRepository] CHECK CONSTRAINT [FK_DOCRepository_Company]
GO

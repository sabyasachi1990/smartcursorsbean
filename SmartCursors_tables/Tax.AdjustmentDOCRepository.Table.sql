USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[AdjustmentDOCRepository]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[AdjustmentDOCRepository](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[AdjustmentType] [nvarchar](500) NULL,
	[FilePath] [nvarchar](500) NULL,
	[DisplayFileName] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[IsDescriptionAdded] [bit] NULL,
	[FileName] [nvarchar](100) NULL,
	[UserName] [nvarchar](500) NULL,
	[Type] [nvarchar](50) NULL,
	[FileSize] [int] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_DOCRepository] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[AdjustmentDOCRepository] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[AdjustmentDOCRepository]  WITH CHECK ADD  CONSTRAINT [FK_DOCRepository_TaxCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[AdjustmentDOCRepository] CHECK CONSTRAINT [FK_DOCRepository_TaxCompanyEngagement]
GO

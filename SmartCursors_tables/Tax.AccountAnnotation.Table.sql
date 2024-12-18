USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[AccountAnnotation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[AccountAnnotation](
	[Id] [uniqueidentifier] NOT NULL,
	[FeatureId] [uniqueidentifier] NULL,
	[FeatureName] [nvarchar](100) NULL,
	[FeatureSection] [nvarchar](100) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TaxCompanyId] [uniqueidentifier] NULL,
	[AnnotationType] [nvarchar](50) NULL,
	[AnnotationTypeId] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](256) NULL,
	[CompanyId] [bigint] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[IsBase] [bit] NULL,
	[Status] [int] NOT NULL,
	[ReferScreenName] [nvarchar](100) NULL,
	[ShortCode] [nvarchar](20) NULL,
	[ReferScreenType] [nvarchar](250) NULL,
	[IsNoteReference] [bit] NULL,
	[CommonId] [uniqueidentifier] NULL,
	[IsReference] [bit] NULL,
	[AccountId] [uniqueidentifier] NULL,
	[GroupName] [nvarchar](100) NULL,
	[Reference] [nvarchar](100) NULL,
	[TemplateId] [nvarchar](100) NULL,
	[Name] [nvarchar](100) NULL,
	[FilePath] [nvarchar](1000) NULL,
	[Description] [nvarchar](1000) NULL,
	[CommentType] [nvarchar](100) NULL,
	[LeadsheetId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AccountNotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[AccountAnnotation]  WITH CHECK ADD  CONSTRAINT [Fk_AccountAnnotation_EngagementId] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[AccountAnnotation] CHECK CONSTRAINT [Fk_AccountAnnotation_EngagementId]
GO

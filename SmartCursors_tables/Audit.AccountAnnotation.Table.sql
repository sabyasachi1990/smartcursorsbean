USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AccountAnnotation]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AccountAnnotation](
	[Id] [uniqueidentifier] NOT NULL,
	[FeatureId] [uniqueidentifier] NULL,
	[FeatureName] [nvarchar](100) NULL,
	[FeatureSection] [nvarchar](100) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[AnnotationType] [nvarchar](50) NULL,
	[AnnotationTypeId] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](4000) NULL,
	[CompanyId] [bigint] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[IsBase] [bit] NULL,
	[CategoryName] [nvarchar](50) NULL,
	[IsReference] [bit] NULL,
	[CommentType] [nvarchar](256) NULL,
	[DynamicGridId] [uniqueidentifier] NULL,
	[IsMigrated] [bit] NULL,
	[GroupName] [nvarchar](50) NULL,
	[LeadsheetId] [uniqueidentifier] NULL,
	[AccountClass] [nvarchar](50) NULL,
	[NoteName] [nvarchar](100) NULL,
	[Name] [nvarchar](max) NULL,
	[Reference] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[MongoId] [nvarchar](100) NULL,
	[AccountId] [uniqueidentifier] NULL,
	[TemplateId] [nvarchar](50) NULL,
	[FilePath] [nvarchar](max) NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AccountNotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[AccountAnnotation] ADD  DEFAULT ((1)) FOR [Status]
GO

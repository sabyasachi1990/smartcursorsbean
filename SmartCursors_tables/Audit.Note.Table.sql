USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Note]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Note](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[LinkTo] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[FeatureName] [nvarchar](100) NULL,
	[FeatureSection] [nvarchar](4000) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[WPShortCode] [nvarchar](50) NULL,
	[DynamicGridId] [uniqueidentifier] NULL,
	[CommentCode] [nvarchar](50) NULL,
	[IsMigrated] [bit] NULL,
	[IsLeadSheetNote] [bit] NULL,
	[DynamicGridData] [nvarchar](max) NULL,
	[DynamicGridTemplate] [nvarchar](max) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[PlanningDescription] [nvarchar](max) NULL,
	[IsSaved] [bit] NOT NULL,
	[IsSection] [bit] NULL,
	[CurrencyName] [nvarchar](50) NULL,
	[YearType] [nvarchar](20) NULL,
	[FeatureId] [uniqueidentifier] NULL,
	[IsExclamatory] [bit] NULL,
	[NoteNumber] [int] NULL,
	[GroupName] [nvarchar](100) NULL,
 CONSTRAINT [PK_Notes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Audit].[Note].[CurrencyName] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Audit].[Note] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[Note] ADD  DEFAULT ((0)) FOR [IsSaved]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AdjustmentDOCRepository_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AdjustmentDOCRepository_ToBeDeleted](
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
ALTER TABLE [Audit].[AdjustmentDOCRepository_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AdjustmentDOCRepository_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_DOCRepository_AuditCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[AdjustmentDOCRepository_ToBeDeleted] CHECK CONSTRAINT [FK_DOCRepository_AuditCompanyEngagement]
GO

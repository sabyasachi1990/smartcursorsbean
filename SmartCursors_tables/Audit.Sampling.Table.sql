USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Sampling]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Sampling](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[AuditMenuId] [uniqueidentifier] NULL,
	[SamplingName] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[PopulationSize] [bigint] NULL,
	[ConfidenceLevel] [int] NULL,
	[MarginofError] [decimal](18, 0) NULL,
	[SampleSize] [int] NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[ShowType] [nvarchar](100) NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[AccountId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](500) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[CatId] [nvarchar](1000) NULL,
	[AccId] [varchar](8000) NULL,
 CONSTRAINT [PK_Sampling] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[Sampling]  WITH CHECK ADD  CONSTRAINT [FK_Sampling_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[Sampling] CHECK CONSTRAINT [FK_Sampling_AuditCompanyEngagement]
GO

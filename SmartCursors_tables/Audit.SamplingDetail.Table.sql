USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[SamplingDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[SamplingDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[SamplingId] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[AuditMenuId] [uniqueidentifier] NULL,
	[Nature] [nvarchar](500) NULL,
	[Date] [datetime2](7) NULL,
	[AccountName] [nvarchar](1000) NULL,
	[Debit] [decimal](17, 2) NULL,
	[Credit] [decimal](17, 2) NULL,
	[DocCurrency] [nvarchar](500) NULL,
	[DocType] [nvarchar](500) NULL,
	[DocNo] [nvarchar](500) NULL,
	[EntityName] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](500) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[RecOrder] [int] NULL,
	[EntitySubType] [nvarchar](200) NULL,
 CONSTRAINT [PK_SamplingDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[SamplingDetail]  WITH CHECK ADD  CONSTRAINT [FK_SamplingDetail_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[SamplingDetail] CHECK CONSTRAINT [FK_SamplingDetail_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[SamplingDetail]  WITH CHECK ADD  CONSTRAINT [FK_SamplingDetail_Sampling] FOREIGN KEY([SamplingId])
REFERENCES [Audit].[Sampling] ([Id])
GO
ALTER TABLE [Audit].[SamplingDetail] CHECK CONSTRAINT [FK_SamplingDetail_Sampling]
GO

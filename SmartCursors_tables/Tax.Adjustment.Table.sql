USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Adjustment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Adjustment](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[AdjustmentType] [nvarchar](50) NULL,
	[Reference] [nvarchar](100) NULL,
	[Explanation] [nvarchar](200) NULL,
	[IsProposed] [bit] NULL,
	[IsMake] [bit] NULL,
	[IsWaive] [bit] NULL,
	[IsDisable] [bit] NULL,
	[AdjustmentName] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[DocDescription] [nvarchar](100) NULL,
 CONSTRAINT [PK_Adjustment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Adjustment] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[Adjustment]  WITH CHECK ADD  CONSTRAINT [FK_Adjustment_AuditCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[Adjustment] CHECK CONSTRAINT [FK_Adjustment_AuditCompanyEngagement]
GO

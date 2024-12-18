USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[CampaignDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[CampaignDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CampaignId] [uniqueidentifier] NOT NULL,
	[ItemName] [nvarchar](254) NOT NULL,
	[BudgetedCost] [money] NULL,
	[ActualCost] [money] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_CampaignDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[CampaignDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[CampaignDetail]  WITH CHECK ADD  CONSTRAINT [FK_CampaignDetail_Campaign] FOREIGN KEY([CampaignId])
REFERENCES [ClientCursor].[Campaign] ([Id])
GO
ALTER TABLE [ClientCursor].[CampaignDetail] CHECK CONSTRAINT [FK_CampaignDetail_Campaign]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ProfitAndLossTickmark]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ProfitAndLossTickmark](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[TickMarkId] [uniqueidentifier] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ProfitAndLossTickmark] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ProfitAndLossTickmark] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ProfitAndLossTickmark]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossTickmark_TaxCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossTickmark] CHECK CONSTRAINT [FK_ProfitAndLossTickmark_TaxCompanyEngagement]
GO
ALTER TABLE [Tax].[ProfitAndLossTickmark]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossTickmark_TickMarkSetup] FOREIGN KEY([TickMarkId])
REFERENCES [Tax].[TickMarkSetup] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossTickmark] CHECK CONSTRAINT [FK_ProfitAndLossTickmark_TickMarkSetup]
GO

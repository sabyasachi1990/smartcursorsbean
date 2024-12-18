USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ForeignExchange]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ForeignExchange](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[NA] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignExchange] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ForeignExchange] ADD  DEFAULT ((0)) FOR [NA]
GO
ALTER TABLE [Tax].[ForeignExchange] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ForeignExchange]  WITH CHECK ADD  CONSTRAINT [FK_ForeignExchange_TaxCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ForeignExchange] CHECK CONSTRAINT [FK_ForeignExchange_TaxCompanyEngagement]
GO

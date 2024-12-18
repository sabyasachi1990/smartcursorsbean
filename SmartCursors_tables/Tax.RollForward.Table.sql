USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[RollForward]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[RollForward](
	[Id] [uniqueidentifier] NOT NULL,
	[OldEngagementId] [uniqueidentifier] NOT NULL,
	[NewEngagementId] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_RollForward] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[RollForward]  WITH CHECK ADD  CONSTRAINT [Fk_RollForward] FOREIGN KEY([OldEngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[RollForward] CHECK CONSTRAINT [Fk_RollForward]
GO

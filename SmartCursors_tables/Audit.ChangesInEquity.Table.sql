USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ChangesInEquity]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ChangesInEquity](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[YearType] [nvarchar](10) NULL,
	[Heading] [nvarchar](100) NULL,
	[Description] [nvarchar](256) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[Recorder] [int] NULL,
	[Type] [nvarchar](200) NULL,
 CONSTRAINT [PK_ChangesInEquity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[ChangesInEquity]  WITH CHECK ADD  CONSTRAINT [FK_ChangesInEquity_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[ChangesInEquity] CHECK CONSTRAINT [FK_ChangesInEquity_AuditCompanyEngagement]
GO

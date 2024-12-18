USE [SmartCursorSTG]
GO
/****** Object:  Table [Report].[ReportCategoryReport]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[ReportCategoryReport](
	[Id] [uniqueidentifier] NOT NULL,
	[ReportCategoryId] [uniqueidentifier] NOT NULL,
	[ReportId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ReportCategoryReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Report].[ReportCategoryReport]  WITH CHECK ADD  CONSTRAINT [FK_ReportCategoryReport_Report] FOREIGN KEY([ReportId])
REFERENCES [Report].[Report] ([Id])
GO
ALTER TABLE [Report].[ReportCategoryReport] CHECK CONSTRAINT [FK_ReportCategoryReport_Report]
GO
ALTER TABLE [Report].[ReportCategoryReport]  WITH CHECK ADD  CONSTRAINT [FK_ReportCategoryReport_ReportCategory] FOREIGN KEY([ReportCategoryId])
REFERENCES [Report].[ReportCategory] ([Id])
GO
ALTER TABLE [Report].[ReportCategoryReport] CHECK CONSTRAINT [FK_ReportCategoryReport_ReportCategory]
GO

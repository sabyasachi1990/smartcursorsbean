USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ProfitAndLossFileDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ProfitAndLossFileDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](275) NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileSize] [int] NULL,
	[IsReconcile] [bit] NULL,
	[AccountType] [nvarchar](8) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ProfitAndLossFileDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ProfitAndLossFileDetails]  WITH CHECK ADD  CONSTRAINT [FK_ProfitAndLossFileDetails_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[ProfitAndLossFileDetails] CHECK CONSTRAINT [FK_ProfitAndLossFileDetails_TaxCompanyEngagement]
GO

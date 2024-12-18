USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[GeneralLedgerFileDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[GeneralLedgerFileDetails](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[FileName] [nvarchar](275) NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileSize] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_GeneralLedgerFileDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[GeneralLedgerFileDetails]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerFileDetails_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[GeneralLedgerFileDetails] CHECK CONSTRAINT [FK_GeneralLedgerFileDetails_TaxCompanyEngagement]
GO

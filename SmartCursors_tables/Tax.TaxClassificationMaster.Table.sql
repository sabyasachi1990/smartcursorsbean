USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxClassificationMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxClassificationMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxManualId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TaxClassificationMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxClassificationMaster]  WITH CHECK ADD  CONSTRAINT [FK_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TaxClassificationMaster] CHECK CONSTRAINT [FK_Company]
GO
ALTER TABLE [Tax].[TaxClassificationMaster]  WITH CHECK ADD  CONSTRAINT [FK_TaxManual] FOREIGN KEY([TaxManualId])
REFERENCES [Tax].[TaxManual] ([Id])
GO
ALTER TABLE [Tax].[TaxClassificationMaster] CHECK CONSTRAINT [FK_TaxManual]
GO

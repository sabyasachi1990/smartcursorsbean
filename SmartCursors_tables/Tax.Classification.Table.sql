USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Classification]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Classification](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Index] [nvarchar](50) NOT NULL,
	[ClassificationType] [nvarchar](50) NOT NULL,
	[AccountClass] [nvarchar](50) NOT NULL,
	[IsSystem] [bit] NULL,
	[ClassificationName] [nvarchar](100) NULL,
	[FinancialStatementTemplate] [nvarchar](50) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Disclosure] [nvarchar](max) NULL,
	[Nature] [nvarchar](50) NULL,
	[Section] [nvarchar](50) NULL,
	[SectionOrder] [int] NULL,
	[MasterId] [uniqueidentifier] NULL,
	[TaxManualId] [uniqueidentifier] NULL,
	[TypeId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Classification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[Classification] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[Classification]  WITH CHECK ADD  CONSTRAINT [FK_Classification_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[Classification] CHECK CONSTRAINT [FK_Classification_Company]
GO
ALTER TABLE [Tax].[Classification]  WITH CHECK ADD  CONSTRAINT [FK_Classification_TaxClassificationMaster] FOREIGN KEY([MasterId])
REFERENCES [Tax].[TaxClassificationMaster] ([Id])
GO
ALTER TABLE [Tax].[Classification] CHECK CONSTRAINT [FK_Classification_TaxClassificationMaster]
GO

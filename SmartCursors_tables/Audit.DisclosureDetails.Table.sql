USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[DisclosureDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[DisclosureDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[DisclosureId] [uniqueidentifier] NOT NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[Type] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[FinalAmount] [decimal](21, 2) NULL,
	[PriorYearAmount] [decimal](21, 2) NULL,
	[IsSystem] [bit] NULL,
	[IsModified] [bit] NULL,
	[RecOrder] [int] NULL,
	[SectionId] [uniqueidentifier] NULL,
	[ColumnsData] [nvarchar](max) NULL,
	[IsLable] [bit] NULL,
	[CategoryName] [nvarchar](256) NULL,
	[IsPriorYear] [bit] NULL,
	[SubTypeName] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[CommonId] [uniqueidentifier] NULL,
	[GroupTypeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_DisclosureDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[DisclosureDetails]  WITH CHECK ADD  CONSTRAINT [FK_DisclosureDetails_Disclosure] FOREIGN KEY([DisclosureId])
REFERENCES [Audit].[Disclosure] ([Id])
GO
ALTER TABLE [Audit].[DisclosureDetails] CHECK CONSTRAINT [FK_DisclosureDetails_Disclosure]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[CompanyTypeSuffix]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[CompanyTypeSuffix](
	[Id] [bigint] NOT NULL,
	[CompanyTypeId] [bigint] NOT NULL,
	[SuffixId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_CompanyTypeSuffix] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[CompanyTypeSuffix]  WITH CHECK ADD  CONSTRAINT [FK_CompanyTypeSuffix_CompanyType] FOREIGN KEY([CompanyTypeId])
REFERENCES [Boardroom].[CompanyType] ([Id])
GO
ALTER TABLE [Boardroom].[CompanyTypeSuffix] CHECK CONSTRAINT [FK_CompanyTypeSuffix_CompanyType]
GO
ALTER TABLE [Boardroom].[CompanyTypeSuffix]  WITH CHECK ADD  CONSTRAINT [FK_CompanyTypeSuffix_Suffix] FOREIGN KEY([SuffixId])
REFERENCES [Boardroom].[Suffix] ([Id])
GO
ALTER TABLE [Boardroom].[CompanyTypeSuffix] CHECK CONSTRAINT [FK_CompanyTypeSuffix_Suffix]
GO

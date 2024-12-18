USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxCompanyContact]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxCompanyContact](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Communication] [nvarchar](1000) NULL,
	[Website] [nvarchar](1000) NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TaxCompanyContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxCompanyContact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TaxCompanyContact]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyContact_Contact] FOREIGN KEY([ContactId])
REFERENCES [Common].[Contact] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyContact] CHECK CONSTRAINT [FK_TaxCompanyContact_Contact]
GO
ALTER TABLE [Tax].[TaxCompanyContact]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyContact_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyContact] CHECK CONSTRAINT [FK_TaxCompanyContact_TaxCompany]
GO

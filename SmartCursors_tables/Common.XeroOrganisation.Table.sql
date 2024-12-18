USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroOrganisation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroOrganisation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[OrgId] [uniqueidentifier] NOT NULL,
	[OrgName] [nvarchar](100) NULL,
	[OrgShortCode] [nvarchar](100) NULL,
	[OrgCurrency] [nvarchar](100) NULL,
	[ConnectedDate] [datetime2](7) NULL,
	[SubCompanyId] [bigint] NULL,
	[ConnectionId] [nvarchar](1000) NULL,
 CONSTRAINT [PK_XeroOrganisation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroOrganisation]  WITH CHECK ADD  CONSTRAINT [FK_XeroOrganisationCompany] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[XeroOrganisation] CHECK CONSTRAINT [FK_XeroOrganisationCompany]
GO

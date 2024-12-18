USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxMenuPermissions]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxMenuPermissions](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCompanyMenuMasterId] [uniqueidentifier] NOT NULL,
	[Role] [nvarchar](100) NULL,
	[View] [bit] NULL,
	[Add] [bit] NULL,
	[Edit] [bit] NULL,
	[Disable] [bit] NULL,
	[Lock] [bit] NULL,
	[Prepared] [bit] NULL,
	[Reviewed] [bit] NULL,
	[DeleteDocument] [bit] NULL,
	[Actions] [nvarchar](2000) NULL,
	[RoleId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TaxMenuPermissions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxMenuPermissions]  WITH CHECK ADD  CONSTRAINT [FK_TaxMenuPermissions_TaxCompanyMenuMaster] FOREIGN KEY([TaxCompanyMenuMasterId])
REFERENCES [Tax].[TaxCompanyMenuMaster] ([Id])
GO
ALTER TABLE [Tax].[TaxMenuPermissions] CHECK CONSTRAINT [FK_TaxMenuPermissions_TaxCompanyMenuMaster]
GO

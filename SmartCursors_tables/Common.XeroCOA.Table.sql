USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroCOA]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroCOA](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[XeroName] [nvarchar](500) NULL,
	[XeroCode] [nvarchar](100) NULL,
	[XeroAccountId] [uniqueidentifier] NOT NULL,
	[XeroClass] [nvarchar](100) NULL,
	[XeroAccountTypeId] [nvarchar](100) NULL,
	[XeroTaxType] [nvarchar](100) NULL,
	[OrganisationId] [uniqueidentifier] NULL,
	[BeanCOAId] [bigint] NULL,
	[UserCreated] [nvarchar](512) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](512) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_XeroCOA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroCOA]  WITH CHECK ADD  CONSTRAINT [FK_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[XeroCOA] CHECK CONSTRAINT [FK_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroAccountType]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroAccountType](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[XeroAccTypeName] [nvarchar](500) NULL,
	[XeroAccTypeId] [bigint] NULL,
	[OrganisationId] [uniqueidentifier] NULL,
	[BeanAccountTypeId] [bigint] NULL,
	[UserCreated] [nvarchar](512) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](512) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_XeroAccountType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroAccountType]  WITH CHECK ADD  CONSTRAINT [FK_XeroAccountTypeCompany] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[XeroAccountType] CHECK CONSTRAINT [FK_XeroAccountTypeCompany]
GO

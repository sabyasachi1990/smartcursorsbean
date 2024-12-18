USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[PayComponent]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[PayComponent](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ShortCode] [nvarchar](10) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[WageType] [nvarchar](50) NOT NULL,
	[IsCPF] [bit] NOT NULL,
	[IsNsPay] [bit] NOT NULL,
	[IsTAX] [bit] NOT NULL,
	[IsSDL] [bit] NOT NULL,
	[IR8AItemSection] [nvarchar](100) NULL,
	[PayMethod] [nvarchar](50) NOT NULL,
	[Amount] [money] NULL,
	[PercentageComponent] [nvarchar](100) NULL,
	[Percentage] [money] NULL,
	[Formula] [nvarchar](254) NULL,
	[IsAdjustable] [bit] NOT NULL,
	[MaxCap] [money] NULL,
	[ApplyTo] [nvarchar](10) NULL,
	[IsExcludeFromGrossWage] [bit] NOT NULL,
	[TaxClassification] [nvarchar](100) NULL,
	[IsSystem] [bit] NULL,
	[DefaultCOA] [nvarchar](50) NULL,
	[DefaultVendor] [nvarchar](50) NULL,
	[Reamrks] [nvarchar](20) NULL,
	[UserCreated] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[COAId] [int] NULL,
	[Category] [nvarchar](200) NULL,
	[Juridication] [nvarchar](50) NULL,
	[IsDefault] [bit] NULL,
	[IsHide] [bit] NULL,
	[IsStatutoryComponent] [bit] NULL,
 CONSTRAINT [PK_PayComponent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[PayComponent]  WITH CHECK ADD  CONSTRAINT [FK_PayComponent_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[PayComponent] CHECK CONSTRAINT [FK_PayComponent_Company]
GO

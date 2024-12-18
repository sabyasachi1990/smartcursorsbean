USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Item]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Item](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[UOM] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[COAId] [bigint] NOT NULL,
	[DefaultTaxcodeId] [bigint] NULL,
	[AllowableDis] [bit] NULL,
	[Notes] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[AppliesTo] [nvarchar](10) NULL,
	[IsEditabled] [bit] NULL,
	[IsAllowable] [bit] NULL,
	[IsSaleItem] [bit] NULL,
	[IsPurchaseItem] [bit] NULL,
	[IsAccountEditable] [bit] NULL,
	[IsAllowableNotAllowableActivated] [bit] NULL,
	[IsPLAccount] [bit] NULL,
	[IsExternalData] [bit] NULL,
	[IsIncidental] [bit] NULL,
	[DocumentId] [bigint] NULL,
	[SyncServiceId] [bigint] NULL,
	[SyncServiceStatus] [varchar](50) NULL,
	[SyncServicedate] [datetime2](7) NULL,
	[SyncServiceRemarks] [nvarchar](max) NULL,
	[IncidentalType] [nvarchar](100) NULL,
 CONSTRAINT [PK_Item] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bean].[Item] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Item]  WITH CHECK ADD  CONSTRAINT [FK_Item_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[Item] CHECK CONSTRAINT [FK_Item_ChartOfAccount]
GO
ALTER TABLE [Bean].[Item]  WITH CHECK ADD  CONSTRAINT [FK_Item_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Item] CHECK CONSTRAINT [FK_Item_Company]
GO
ALTER TABLE [Bean].[Item]  WITH CHECK ADD  CONSTRAINT [FK_Item_TaxCode] FOREIGN KEY([DefaultTaxcodeId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Bean].[Item] CHECK CONSTRAINT [FK_Item_TaxCode]
GO

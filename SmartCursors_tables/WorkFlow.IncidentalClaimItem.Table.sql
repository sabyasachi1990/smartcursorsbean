USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[IncidentalClaimItem]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[IncidentalClaimItem](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ItemDescription] [nvarchar](100) NULL,
	[ChargeBy] [nvarchar](30) NULL,
	[TaxCodeId] [bigint] NULL,
	[Tax] [nvarchar](50) NULL,
	[Charge] [money] NULL,
	[MinCharge] [money] NULL,
	[FeePercentage] [float] NULL,
	[ClaimUnit] [nvarchar](25) NULL,
	[COAName] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Item] [nvarchar](100) NOT NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[COAId] [int] NULL,
	[IncidentalType] [nvarchar](100) NULL,
 CONSTRAINT [PK_IncidentalClaimItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[IncidentalClaimItem]  WITH CHECK ADD  CONSTRAINT [FK_IncidentalClaimItem_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[IncidentalClaimItem] CHECK CONSTRAINT [FK_IncidentalClaimItem_Company]
GO
ALTER TABLE [WorkFlow].[IncidentalClaimItem]  WITH CHECK ADD  CONSTRAINT [FK_IncidentalClaimItem_TaxCode] FOREIGN KEY([TaxCodeId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [WorkFlow].[IncidentalClaimItem] CHECK CONSTRAINT [FK_IncidentalClaimItem_TaxCode]
GO

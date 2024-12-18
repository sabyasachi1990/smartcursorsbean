USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Charge]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Charge](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ChangeNumber] [nvarchar](100) NOT NULL,
	[ChargeType] [nvarchar](15) NOT NULL,
	[DateofCreation] [datetime2](7) NOT NULL,
	[DateofRegistration] [datetime2](7) NOT NULL,
	[Chargee] [nvarchar](max) NULL,
	[SecureAllMonies] [nvarchar](10) NULL,
	[Currency] [nvarchar](100) NULL,
	[Amount] [decimal](18, 2) NULL,
	[LodgedBehalfOf] [nvarchar](250) NULL,
	[TypeofLodgement] [nvarchar](250) NULL,
	[Description] [nvarchar](2000) NULL,
	[Instrument] [nvarchar](max) NULL,
	[InstrumentOption] [bit] NULL,
	[Executed] [nvarchar](100) NULL,
	[InstrumentDate] [datetime2](7) NULL,
	[TrusteeNames] [nvarchar](50) NULL,
	[TypeofInstrument] [nvarchar](250) NULL,
	[InstrumnentDescriptions] [nvarchar](max) NULL,
	[Purpose] [nvarchar](max) NULL,
	[Others] [nvarchar](1000) NULL,
	[DateofSatisfaction] [datetime2](7) NULL,
	[NatureofSatisfaction] [nvarchar](100) NULL,
	[AmountSatisfied] [decimal](18, 2) NULL,
	[Remarks] [nvarchar](2000) NULL,
	[Recorder] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Charge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Charge]  WITH CHECK ADD  CONSTRAINT [FK_Charge_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Charge] CHECK CONSTRAINT [FK_Charge_CompanyId]
GO
ALTER TABLE [Boardroom].[Charge]  WITH CHECK ADD  CONSTRAINT [FK_Charge_EntityId] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Charge] CHECK CONSTRAINT [FK_Charge_EntityId]
GO

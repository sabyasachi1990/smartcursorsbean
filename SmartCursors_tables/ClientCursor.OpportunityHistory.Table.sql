USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[ServiceCompanyId] [bigint] NULL,
	[ServiceGroupId] [bigint] NULL,
	[ServiceId] [bigint] NULL,
	[QuoteNumber] [nvarchar](50) NULL,
	[Type] [nvarchar](20) NULL,
	[Stage] [nvarchar](20) NULL,
	[Nature] [nvarchar](50) NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[ReOpen] [datetime2](7) NULL,
	[Frequency] [nvarchar](20) NULL,
	[FeeType] [nvarchar](20) NULL,
	[Fee] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[RecommendedFee] [money] NULL,
	[RecoCurrency] [nvarchar](5) NULL,
	[TargettedRecovery] [float] NULL,
	[TotalEstdHours] [float] NULL,
	[SpecialRemarks] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[OpportunityCreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsRecurring] [bit] NULL,
	[IsAdHoc] [bit] NULL,
	[OpportunityNumber] [nvarchar](50) NULL,
	[RecurringScopeofWork] [nvarchar](4000) NULL,
	[StandardTerms] [uniqueidentifier] NULL,
	[KeyTerms] [uniqueidentifier] NULL,
	[RevisionCreatedDate] [datetime2](7) NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[BaseFee] [money] NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
 CONSTRAINT [PK_OpportunityHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityHistory] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[OpportunityHistory]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityHistory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityHistory] CHECK CONSTRAINT [FK_OpportunityHistory_Company]
GO
ALTER TABLE [ClientCursor].[OpportunityHistory]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityHistory_Oppurtunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityHistory] CHECK CONSTRAINT [FK_OpportunityHistory_Oppurtunity]
GO

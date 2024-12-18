USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxCompanyEngagement]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxCompanyEngagement](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NOT NULL,
	[ProjectName] [nvarchar](100) NOT NULL,
	[YearEndDate] [datetime2](7) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Description] [nvarchar](256) NULL,
	[DueDate] [datetime2](7) NULL,
	[EngagementType] [nvarchar](100) NULL,
	[EngagementFee] [money] NOT NULL,
	[EngagementReviewLevel] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[yearOfAssessment] [int] NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[FunctionalCurrency] [nvarchar](10) NULL,
	[ExchangeRate] [decimal](17, 4) NULL,
	[ExemptionType] [nvarchar](100) NULL,
	[TaxType] [nvarchar](100) NULL,
	[PlaceofControl] [nvarchar](100) NULL,
	[StatementBOrder] [nvarchar](max) NULL,
	[IsFirstTimeRollForward] [bit] NULL,
	[TaxManualId] [uniqueidentifier] NULL,
	[CheckListId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TaxCompanyEngagement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxCompanyEngagement] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TaxCompanyEngagement]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyEngagement_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyEngagement] CHECK CONSTRAINT [FK_TaxCompanyEngagement_TaxCompany]
GO

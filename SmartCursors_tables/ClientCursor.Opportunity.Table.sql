USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[Opportunity]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[Opportunity](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[ServiceId] [bigint] NOT NULL,
	[QuoteNumber] [nvarchar](50) NULL,
	[Type] [nvarchar](20) NOT NULL,
	[Stage] [nvarchar](20) NOT NULL,
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
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsRecurring] [bit] NULL,
	[IsAdHoc] [bit] NULL,
	[OpportunityNumber] [nvarchar](50) NULL,
	[RecurringScopeofWork] [nvarchar](4000) NULL,
	[ReportPath] [nvarchar](1000) NULL,
	[ScopeOfWork] [uniqueidentifier] NULL,
	[StandardTerms] [uniqueidentifier] NULL,
	[KeyTerms] [uniqueidentifier] NULL,
	[KeyTemplateContent] [nvarchar](max) NULL,
	[IsModify] [bit] NULL,
	[StandardTemplateContent] [nvarchar](max) NULL,
	[MainServiceFee] [money] NULL,
	[SubServiceFee] [money] NULL,
	[NextFromDate] [datetime2](7) NULL,
	[NextToDate] [datetime2](7) NULL,
	[CaseId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[ReasonForCancellation] [nvarchar](256) NULL,
	[MainServiceId] [int] NULL,
	[SubServiceId] [int] NULL,
	[OpportunityRemarks] [nvarchar](2000) NULL,
	[IsEnableKeyTerms] [bit] NULL,
	[IsEnableStandardTerms] [bit] NULL,
	[StadardTemplateName] [nvarchar](200) NULL,
	[KeyTemplateName] [nvarchar](200) NULL,
	[IsCreatedBeforeWorkflowActivate] [bit] NULL,
	[IsAccount] [bit] NULL,
	[IsTemp] [bit] NULL,
	[ReOpeningDate] [datetime] NULL,
	[SyncCaseId] [uniqueidentifier] NULL,
	[SyncCaseStatus] [nvarchar](100) NULL,
	[SyncCaseDate] [datetime2](7) NULL,
	[SyncCaseRemarks] [nvarchar](max) NULL,
	[OppNumberFormat] [nvarchar](100) NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[BaseFee] [money] NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
	[IsMultiCurrency] [bit] NULL,
	[IsPrecedingAuditor] [bit] NULL,
	[IsSucceedingAuditor] [bit] NULL,
	[IsAssuranceResignationDate] [bit] NULL,
	[IsReasonForResignation] [bit] NULL,
	[PrecedingAuditor] [nvarchar](max) NULL,
	[SucceedingAuditor] [nvarchar](max) NULL,
	[AssuranceResignationDate] [datetime2](7) NULL,
	[ReasonForResignation] [nvarchar](max) NULL,
	[IsAdditionalSettings] [bit] NULL,
	[IsOpportunityReopen] [bit] NULL,
	[Period] [nvarchar](200) NULL,
	[NoOfDays] [float] NULL,
	[FromToDate] [nvarchar](200) NULL,
	[OperatorSymbol] [nvarchar](200) NULL,
 CONSTRAINT [PK_Opportunity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Opportunity].[Currency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [ClientCursor].[Opportunity].[RecoCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [ClientCursor].[Opportunity] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[Opportunity] ADD  DEFAULT ((1)) FOR [IsRecurring]
GO
ALTER TABLE [ClientCursor].[Opportunity] ADD  DEFAULT ((1)) FOR [IsAdHoc]
GO
ALTER TABLE [ClientCursor].[Opportunity]  WITH CHECK ADD  CONSTRAINT [FK_Opportunity_Account] FOREIGN KEY([AccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [ClientCursor].[Opportunity] CHECK CONSTRAINT [FK_Opportunity_Account]
GO
ALTER TABLE [ClientCursor].[Opportunity]  WITH CHECK ADD  CONSTRAINT [FK_Opportunity_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[Opportunity] CHECK CONSTRAINT [FK_Opportunity_Company]
GO
ALTER TABLE [ClientCursor].[Opportunity]  WITH CHECK ADD  CONSTRAINT [FK_Opportunity_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [ClientCursor].[Opportunity] CHECK CONSTRAINT [FK_Opportunity_Service]
GO
ALTER TABLE [ClientCursor].[Opportunity]  WITH CHECK ADD  CONSTRAINT [FK_Opportunity_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [ClientCursor].[Opportunity] CHECK CONSTRAINT [FK_Opportunity_ServiceGroup]
GO

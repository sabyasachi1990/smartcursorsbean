USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseGroup]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseGroup](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[ServiceId] [bigint] NOT NULL,
	[Type] [nvarchar](20) NOT NULL,
	[Stage] [nvarchar](20) NOT NULL,
	[Nature] [nvarchar](50) NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[FeeType] [nvarchar](20) NULL,
	[Fee] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[RecommendedFee] [money] NULL,
	[RecoCurrency] [nvarchar](5) NULL,
	[TargettedRecovery] [float] NULL,
	[TotalEstdHours] [float] NULL,
	[CaseNumber] [nvarchar](50) NULL,
	[SpecialRemarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[SystemRefNo] [nvarchar](100) NOT NULL,
	[OpportunityId] [uniqueidentifier] NULL,
	[TillDate] [datetime2](7) NULL,
	[CaseAgening] [int] NULL,
	[CaseTurnAroundDate] [datetime2](7) NULL,
	[ApprovedDate] [datetime2](7) NULL,
	[AssignedDate] [datetime2](7) NULL,
	[Likelihood] [nvarchar](20) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[InvoiceState] [nvarchar](20) NULL,
	[IsMainService] [bit] NULL,
	[MainOrSubCaseId] [uniqueidentifier] NULL,
	[ActualDateOfCompletion] [datetime2](7) NULL,
	[ReasonForCancellation] [nvarchar](256) NULL,
	[IsServiceNatureWOWF] [bit] NULL,
	[IsMoveSchedule] [bit] NULL,
	[IsMoveScheduleAndTimelog] [bit] NULL,
	[CancelledCaseId] [uniqueidentifier] NULL,
	[ScopeOfWork] [nvarchar](4000) NULL,
	[ServiceNatureType] [bit] NULL,
	[DueDateForCompletion] [datetime2](7) NULL,
	[SyncOppId] [uniqueidentifier] NULL,
	[SyncOppStatus] [nvarchar](100) NULL,
	[SyncOppDate] [datetime2](7) NULL,
	[SyncOppRemarks] [nvarchar](max) NULL,
	[FullyInvoicedDate] [datetime2](7) NULL,
	[CanceledDate] [datetime2](7) NULL,
	[CaseState] [nvarchar](50) NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[BaseFee] [money] NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
	[IsMultiCurrency] [bit] NULL,
	[ScheduleStartDate] [datetime2](7) NULL,
	[ScheduleEndDate] [datetime2](7) NULL,
	[PrimaryEmployeeName] [nvarchar](250) NULL,
	[AmendDate] [datetime2](7) NULL,
	[QualityInchargeEmployeeName] [nvarchar](250) NULL,
	[IsAllowQic] [bit] NULL,
	[IsAllowJobDeadLine] [bit] NULL,
	[IsAllowEmail] [bit] NULL,
	[ManagerInchargeEmployeeName] [nvarchar](2000) NULL,
	[IsAllowMic] [bit] NULL,
	[CompleteDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Case] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseGroup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseGroup]  WITH CHECK ADD  CONSTRAINT [FK_Case_Client] FOREIGN KEY([ClientId])
REFERENCES [WorkFlow].[Client] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseGroup] CHECK CONSTRAINT [FK_Case_Client]
GO
ALTER TABLE [WorkFlow].[CaseGroup]  WITH CHECK ADD  CONSTRAINT [FK_Case_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseGroup] CHECK CONSTRAINT [FK_Case_Company]
GO
ALTER TABLE [WorkFlow].[CaseGroup]  WITH CHECK ADD  CONSTRAINT [FK_Case_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseGroup] CHECK CONSTRAINT [FK_Case_Opportunity]
GO
ALTER TABLE [WorkFlow].[CaseGroup]  WITH CHECK ADD  CONSTRAINT [FK_Case_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseGroup] CHECK CONSTRAINT [FK_Case_Service]
GO
ALTER TABLE [WorkFlow].[CaseGroup]  WITH CHECK ADD  CONSTRAINT [FK_Case_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseGroup] CHECK CONSTRAINT [FK_Case_ServiceGroup]
GO

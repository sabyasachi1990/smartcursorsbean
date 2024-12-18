USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Service]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Service](
	[Id] [bigint] NOT NULL,
	[Code] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsRecurring] [bit] NULL,
	[IsRenewal] [bit] NULL,
	[IsAdHoc] [bit] NULL,
	[IsFixesFeeType] [bit] NULL,
	[IsVariableFeeType] [bit] NULL,
	[TargettedRecovery] [float] NULL,
	[IsAdHocFromToDate] [bit] NULL,
	[AdhocScopeOfWork] [nvarchar](4000) NULL,
	[RecurringScopeofWork] [nvarchar](4000) NULL,
	[CompanyId] [bigint] NULL,
	[IsMonthly] [bit] NULL,
	[IsQuarterly] [bit] NULL,
	[IsSemiAnnually] [bit] NULL,
	[IsAnnually] [bit] NULL,
	[KeyTermsTemplateId] [uniqueidentifier] NULL,
	[StandardTermsTemplateId] [uniqueidentifier] NULL,
	[DefaultTemplateId] [uniqueidentifier] NULL,
	[ApplicableTaxCode] [nvarchar](20) NULL,
	[IsSplitEnable] [bit] NULL,
	[MainServiceId] [int] NULL,
	[SubServiceId] [int] NULL,
	[MainServiceCode] [nvarchar](20) NULL,
	[SubServiceCode] [nvarchar](20) NULL,
	[KeyTermsContent] [nvarchar](max) NULL,
	[StandardTermsContent] [nvarchar](max) NULL,
	[QuotationContent] [nvarchar](max) NULL,
	[IsRecurringWOWF] [bit] NULL,
	[IsAdHocWOWF] [bit] NULL,
	[IsGSTActivate] [bit] NULL,
	[CoaId] [bigint] NULL,
	[TaxCodeId] [bigint] NULL,
	[ApprovalName] [varchar](50) NULL,
	[ApprovalDate] [varchar](50) NULL,
	[Days] [int] NULL,
	[ApprovalDaysAndMonths] [varchar](20) NULL,
	[SyncItemId] [uniqueidentifier] NULL,
	[SyncItemStatus] [nvarchar](100) NULL,
	[SyncItemDate] [datetime2](7) NULL,
	[SyncItemRemarks] [nvarchar](max) NULL,
	[IsAllowQic] [bit] NULL,
	[IsAllowJobDeadLine] [bit] NULL,
	[IsAllowEmail] [bit] NULL,
	[IsPrecedingAuditor] [bit] NULL,
	[IsSucceedingAuditor] [bit] NULL,
	[IsAssuranceResignationDate] [bit] NULL,
	[IsReasonForResignation] [bit] NULL,
	[IsAdditionalSettings] [bit] NULL,
	[IsAllowMic] [bit] NULL,
	[IsCheckCompleteDate] [bit] NULL,
 CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Service] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Service] ADD  DEFAULT ((1)) FOR [IsMonthly]
GO
ALTER TABLE [Common].[Service] ADD  DEFAULT ((1)) FOR [IsQuarterly]
GO
ALTER TABLE [Common].[Service] ADD  DEFAULT ((1)) FOR [IsSemiAnnually]
GO
ALTER TABLE [Common].[Service] ADD  DEFAULT ((1)) FOR [IsAnnually]
GO
ALTER TABLE [Common].[Service]  WITH CHECK ADD FOREIGN KEY([CoaId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Common].[Service]  WITH CHECK ADD FOREIGN KEY([TaxCodeId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Common].[Service]  WITH CHECK ADD  CONSTRAINT [FK_Service_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Service] CHECK CONSTRAINT [FK_Service_Company]
GO
ALTER TABLE [Common].[Service]  WITH CHECK ADD  CONSTRAINT [FK_Service_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[Service] CHECK CONSTRAINT [FK_Service_ServiceGroup]
GO

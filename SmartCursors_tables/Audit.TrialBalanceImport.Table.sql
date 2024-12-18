USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TrialBalanceImport]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TrialBalanceImport](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[AccountNumber] [nvarchar](100) NULL,
	[AccountName] [nvarchar](100) NULL,
	[AccountDesc] [nvarchar](200) NULL,
	[CYDebit] [money] NULL,
	[CYCredit] [money] NULL,
	[TransactionDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[CurrentBalance] [money] NULL,
	[PreviousYearBalance] [money] NULL,
	[PBCBalance] [money] NULL,
	[PYDebit] [money] NULL,
	[PYCredit] [money] NULL,
	[CYBalance] [money] NULL,
	[AmountChange] [money] NULL,
	[AJEs] [money] NULL,
	[Final] [money] NULL,
	[ReconcileId] [uniqueidentifier] NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[FileId] [uniqueidentifier] NULL,
	[ModifiedFlag] [int] NULL,
	[AccountType] [nvarchar](8) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsRoundOff] [bit] NULL,
	[IsOverride] [bit] NULL,
	[CategoryId] [uniqueidentifier] NULL,
	[IsCyCurrent] [bit] NULL,
	[IsPyCurrent] [bit] NULL,
	[Difference] [decimal](15, 5) NULL,
	[IsReconcile] [bit] NULL,
	[SubCategoryId] [uniqueidentifier] NULL,
	[SOEPriorYear] [decimal](10, 2) NULL,
	[SOEPYAccountDescription] [nvarchar](256) NULL,
	[SOECYAccountDescription] [nvarchar](256) NULL,
	[UserCategoryId] [uniqueidentifier] NULL,
	[SOEPYAccountRecOrder] [int] NULL,
	[SOECYAccountRecOrder] [int] NULL,
	[IsCollapse] [bit] NULL,
	[TrialBalanceOrder] [int] NULL,
	[CYRoundOffValue] [decimal](18, 0) NULL,
	[PYRoundOffValue] [decimal](18, 0) NULL,
	[ActualCYAmount] [money] NULL,
	[ActualPYAmount] [money] NULL,
	[InterimMultiplierAmount] [money] NULL,
	[InterimDebit] [money] NULL,
	[InterimCredit] [money] NULL,
	[InterimBalance] [money] NULL,
 CONSTRAINT [PK_TrialBalanceImport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[TrialBalanceImport] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[TrialBalanceImport]  WITH CHECK ADD  CONSTRAINT [FK_TrialBalanceImport_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[TrialBalanceImport] CHECK CONSTRAINT [FK_TrialBalanceImport_AuditCompany]
GO
ALTER TABLE [Audit].[TrialBalanceImport]  WITH CHECK ADD  CONSTRAINT [FK_TrialBalanceImport_ClientEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[TrialBalanceImport] CHECK CONSTRAINT [FK_TrialBalanceImport_ClientEngagement]
GO

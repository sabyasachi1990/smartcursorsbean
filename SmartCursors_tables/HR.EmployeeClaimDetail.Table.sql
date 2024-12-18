USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeClaimDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeClaimDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeClaimId] [uniqueidentifier] NOT NULL,
	[ClaimItemId] [uniqueidentifier] NULL,
	[TaxId] [bigint] NULL,
	[Currency] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ApprovedAmount] [money] NULL,
	[TaxRate] [money] NULL,
	[TaxAmount] [money] NULL,
	[BaseAmount] [decimal](17, 2) NULL,
	[Amount] [decimal](17, 2) NULL,
	[ClaimDate] [datetime2](7) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[Recorder] [int] NULL,
	[IncidentalClaimItemId] [uniqueidentifier] NULL,
	[IsWorkflowCursor] [bit] NULL,
	[SyncWFClaimId] [uniqueidentifier] NULL,
	[SyncWFClaimDate] [datetime2](7) NULL,
	[SyncWFClaimRemarks] [nvarchar](max) NULL,
	[SyncWFClaimStatus] [nvarchar](100) NULL,
	[ChangeExchangeRate] [decimal](15, 10) NULL,
	[ischeck] [bit] NULL,
	[IsSplit] [bit] NULL,
	[JurToWFDocExhRate] [decimal](15, 10) NULL,
	[WFDocToBaseExhRate] [decimal](15, 10) NULL,
	[CaseDocCurrency] [nvarchar](10) NULL,
 CONSTRAINT [PK_EmployeeClaimDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeClaimDetail]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaimDetail] CHECK CONSTRAINT [FK_EmployeeClaim_TaxCode]
GO
ALTER TABLE [HR].[EmployeeClaimDetail]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaimDetail_ClaimItem] FOREIGN KEY([ClaimItemId])
REFERENCES [HR].[ClaimItem] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaimDetail] CHECK CONSTRAINT [FK_EmployeeClaimDetail_ClaimItem]
GO
ALTER TABLE [HR].[EmployeeClaimDetail]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaimDetail_EmployeeClaim] FOREIGN KEY([EmployeeClaimId])
REFERENCES [HR].[EmployeeClaim1] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaimDetail] CHECK CONSTRAINT [FK_EmployeeClaimDetail_EmployeeClaim]
GO

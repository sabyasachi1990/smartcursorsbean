USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Claim]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Claim](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[ClaimDate] [datetime2](7) NULL,
	[Category] [nvarchar](100) NULL,
	[Item] [nvarchar](50) NULL,
	[Descriptions] [nvarchar](256) NULL,
	[Amount] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[IsSystem] [bit] NULL,
	[IsSystemId] [uniqueidentifier] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[HrStatus] [nvarchar](100) NULL,
	[ClaimantName] [nvarchar](200) NULL,
	[ClaimNumber] [nvarchar](100) NULL,
	[SyncHRClaimId] [uniqueidentifier] NULL,
	[SyncHRClaimStatus] [nvarchar](100) NULL,
	[SyncHRClaimDate] [datetime2](7) NULL,
	[SyncHRClaimRemarks] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[SyncHRClaimParentId] [uniqueidentifier] NULL,
	[ClaimYearId] [uniqueidentifier] NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[BaseAmount] [money] NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
 CONSTRAINT [PK_Claim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Claim]  WITH CHECK ADD  CONSTRAINT [FK_Claim_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[Claim] CHECK CONSTRAINT [FK_Claim_CaseGroup]
GO
ALTER TABLE [WorkFlow].[Claim]  WITH CHECK ADD  CONSTRAINT [FK_Claim_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[Claim] CHECK CONSTRAINT [FK_Claim_Company]
GO

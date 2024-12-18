USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeClaim1]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeClaim1](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ParentCompanyId] [bigint] NOT NULL,
	[EmployeId] [uniqueidentifier] NOT NULL,
	[ClaimEntitlementId] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NULL,
	[CaseGroupId] [uniqueidentifier] NULL,
	[ClaimNumber] [nvarchar](100) NULL,
	[Verifiers] [nvarchar](1000) NULL,
	[ClaimStatus] [nvarchar](100) NULL,
	[ApprovedDate] [datetime2](7) NULL,
	[ReviwedDate] [datetime2](7) NULL,
	[VerifiedDate] [datetime2](7) NULL,
	[ProcessedDate] [datetime2](7) NULL,
	[ApprovedBy] [uniqueidentifier] NULL,
	[VerifiedBy] [uniqueidentifier] NULL,
	[ReviewedBy] [uniqueidentifier] NULL,
	[ProcessedBy] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[MasterClaimDate] [datetime2](7) NULL,
	[MongoId] [nvarchar](2000) NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[IsGstEnable] [bit] NOT NULL,
	[ApprovedId] [bigint] NULL,
	[ReviewedId] [bigint] NULL,
	[ProcessedId] [bigint] NULL,
	[VerifiedId] [bigint] NULL,
	[VerifierIds] [nvarchar](1000) NULL,
	[SyncBCClaimId] [uniqueidentifier] NULL,
	[SyncBCClaimDate] [datetime2](7) NULL,
	[SyncBCClaimRemarks] [nvarchar](max) NULL,
	[SyncBCClaimStatus] [nvarchar](100) NULL,
	[PostingDate] [datetime2](7) NULL,
	[Ispaycomponent] [bit] NULL,
	[Isvendor] [bit] NULL,
	[VendorId] [uniqueidentifier] NULL,
	[BatchId] [nvarchar](100) NULL,
	[ApproverIds] [nvarchar](1000) NULL,
	[ReviewerIds] [nvarchar](1000) NULL,
	[HRSettingDetailId] [uniqueidentifier] NULL,
	[DepartmentName] [nvarchar](500) NULL,
	[DesignationName] [nvarchar](500) NULL,
	[TotalApprovedAmount] [money] NULL,
	[TotalBaseAmount] [money] NULL,
	[IsAllowClaimCategory] [bit] NULL,
	[Category] [nvarchar](2000) NULL,
	[PayrollStatus] [nvarchar](max) NULL,
	[PayrollId] [uniqueidentifier] NULL,
	[PayrollYearMonth] [nvarchar](max) NULL,
 CONSTRAINT [PK_EmployeeClaim] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeClaim1] ADD  DEFAULT ((0)) FOR [IsGstEnable]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_CaseGroup] FOREIGN KEY([CaseGroupId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_CaseGroup]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_ClaimsEntitlement] FOREIGN KEY([ClaimEntitlementId])
REFERENCES [HR].[EmployeeClaimsEntitlement] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_ClaimsEntitlement]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_Client] FOREIGN KEY([ClientId])
REFERENCES [WorkFlow].[Client] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_Client]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_Company]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_Department]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_DepartmentDesignation]
GO
ALTER TABLE [HR].[EmployeeClaim1]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaim_Employee] FOREIGN KEY([EmployeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaim1] CHECK CONSTRAINT [FK_EmployeeClaim_Employee]
GO

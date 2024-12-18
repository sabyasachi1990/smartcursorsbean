USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[HRSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[HRSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ResetLeaveBalanceType] [nvarchar](50) NOT NULL,
	[ResetLeaveBalanceDate] [datetime2](7) NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](30) NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[CustomYear] [int] NULL,
	[CustomMonth] [nvarchar](15) NULL,
	[IsExistEmployeeAutoNumber] [bit] NOT NULL,
	[CarryforwardResetDate] [datetime] NULL,
	[IsHideAppraiserName] [bit] NULL,
	[IsSelfAppraisal] [bit] NULL,
	[Includepaycomponent] [bit] NULL,
	[ClaimsCarryforwardResetDate] [datetime] NULL,
	[IsAllowPayslipPreview] [bit] NULL,
	[IsAllowAllServiceentitiesForLeaves] [bit] NULL,
	[IsAllowAllServiceentitiesForClaims] [bit] NULL,
	[IsAllowAllServiceentitiesForAppraisal] [bit] NULL,
	[IsAllowClaimCategory] [bit] NULL,
	[VerifierIds] [nvarchar](max) NULL,
	[ReviewerIds] [nvarchar](max) NULL,
	[ApproverIds] [nvarchar](max) NULL,
	[VerifierNames] [nvarchar](max) NULL,
	[ReviewerNames] [nvarchar](max) NULL,
	[ApproverNames] [nvarchar](max) NULL,
	[IsNotRequiredApprover] [bit] NULL,
	[IsNotRequiredReviewer] [bit] NULL,
	[IsNotRequiredVerifier] [bit] NULL,
	[PayrollRunMode] [nvarchar](20) NULL,
	[RetirementAge] [int] NULL,
 CONSTRAINT [PK_LeavesReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[HRSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[HRSettings] ADD  DEFAULT ((0)) FOR [IsExistEmployeeAutoNumber]
GO
ALTER TABLE [Common].[HRSettings]  WITH CHECK ADD  CONSTRAINT [FK_LeavesReport_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[HRSettings] CHECK CONSTRAINT [FK_LeavesReport_Company]
GO

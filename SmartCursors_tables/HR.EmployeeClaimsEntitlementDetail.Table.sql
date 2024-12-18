USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeeClaimsEntitlementDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeeClaimsEntitlementDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeClaimsEntitlementId] [uniqueidentifier] NOT NULL,
	[Year] [int] NOT NULL,
	[ClaimType] [nvarchar](20) NOT NULL,
	[ClaimItemId] [uniqueidentifier] NOT NULL,
	[CategoryLimit] [money] NULL,
	[TransactionLimit] [money] NULL,
	[AnnualLimit] [money] NULL,
	[UtilizedAmount] [money] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[Status] [int] NULL,
	[IsCategoryDisable] [bit] NULL,
	[CategoryUtilizedAmount] [decimal](17, 2) NULL,
	[CategoryPreApprovedAmount] [decimal](17, 2) NULL,
	[CategoryBalanceAmount] [decimal](17, 2) NULL,
	[SubmittedAmount] [decimal](17, 2) NULL,
	[RemainingAmount] [decimal](17, 2) NULL,
	[HrSettingDetaiId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EmployeeClaimsEntitlementDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeeClaimsEntitlementDetail]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeClaimsEntitlementDetail_ClaimItem] FOREIGN KEY([ClaimItemId])
REFERENCES [HR].[ClaimItem] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaimsEntitlementDetail] CHECK CONSTRAINT [FK_EmployeeClaimsEntitlementDetail_ClaimItem]
GO
ALTER TABLE [HR].[EmployeeClaimsEntitlementDetail]  WITH CHECK ADD  CONSTRAINT [fk_EmployeeClaimsEntitlementDetail_EmployeeClaimsEntitlement] FOREIGN KEY([EmployeeClaimsEntitlementId])
REFERENCES [HR].[EmployeeClaimsEntitlement] ([Id])
GO
ALTER TABLE [HR].[EmployeeClaimsEntitlementDetail] CHECK CONSTRAINT [fk_EmployeeClaimsEntitlementDetail_EmployeeClaimsEntitlement]
GO

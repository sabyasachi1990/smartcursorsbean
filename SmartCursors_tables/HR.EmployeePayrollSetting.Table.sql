USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EmployeePayrollSetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EmployeePayrollSetting](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[WorkProfileId] [uniqueidentifier] NOT NULL,
	[AgencyFundId] [uniqueidentifier] NULL,
	[AgencyFund] [nvarchar](1000) NULL,
	[AgencyOptOutDate] [datetime2](7) NULL,
	[IsCPFContributionFull] [bit] NULL,
	[PayMode] [nvarchar](256) NULL,
	[SDLExempted] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreateDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[CPFExempted] [bit] NULL,
	[PaySlipPassword] [nvarchar](100) NULL,
	[ExcludePayroll] [bit] NULL,
	[IsPasswordChange] [bit] NULL,
	[AgencyFundIds] [nvarchar](500) NULL,
	[IsAgencyFundNotApplicable] [bit] NULL,
 CONSTRAINT [PK_EmployeePayrollSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EmployeePayrollSetting]  WITH CHECK ADD  CONSTRAINT [FK_EmployeePayrollSetting_AgencyFund] FOREIGN KEY([AgencyFundId])
REFERENCES [HR].[AgencyFund] ([Id])
GO
ALTER TABLE [HR].[EmployeePayrollSetting] CHECK CONSTRAINT [FK_EmployeePayrollSetting_AgencyFund]
GO
ALTER TABLE [HR].[EmployeePayrollSetting]  WITH CHECK ADD  CONSTRAINT [FK_EmployeePayrollSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EmployeePayrollSetting] CHECK CONSTRAINT [FK_EmployeePayrollSetting_Company]
GO
ALTER TABLE [HR].[EmployeePayrollSetting]  WITH CHECK ADD  CONSTRAINT [FK_EmployeePayrollSetting_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[EmployeePayrollSetting] CHECK CONSTRAINT [FK_EmployeePayrollSetting_Employee]
GO
ALTER TABLE [HR].[EmployeePayrollSetting]  WITH CHECK ADD  CONSTRAINT [FK_EmployeePayrollSetting_WorkProfile] FOREIGN KEY([WorkProfileId])
REFERENCES [HR].[WorkProfile] ([Id])
GO
ALTER TABLE [HR].[EmployeePayrollSetting] CHECK CONSTRAINT [FK_EmployeePayrollSetting_WorkProfile]
GO

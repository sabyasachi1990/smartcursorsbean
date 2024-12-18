USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Employee]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Employee](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Title] [nvarchar](10) NULL,
	[Gender] [nvarchar](10) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[DOB] [datetime2](7) NULL,
	[Username] [nvarchar](254) NULL,
	[Email] [nvarchar](254) NULL,
	[Role] [nvarchar](254) NULL,
	[PhotoId] [uniqueidentifier] NULL,
	[DeactivationDate] [datetime2](7) NULL,
	[MetadataValues] [nvarchar](4000) NULL,
	[DateOfJoin] [datetime2](7) NULL,
	[UsecompanyWorkProfile] [bit] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Communication] [nvarchar](1000) NULL,
	[EmployeeType] [nvarchar](20) NULL,
	[EmployeeId] [nvarchar](50) NULL,
	[MobileNo] [nvarchar](20) NULL,
	[Designation] [nvarchar](50) NULL,
	[Nationality] [nvarchar](30) NULL,
	[CountryOfOrigin] [nvarchar](30) NULL,
	[MaritalStatus] [nvarchar](20) NULL,
	[Race] [nvarchar](20) NULL,
	[Religion] [nvarchar](20) NULL,
	[MemberShip] [nvarchar](20) NULL,
	[IdNo] [nvarchar](20) NULL,
	[ResidenceStatus] [nvarchar](20) NULL,
	[IdType] [nvarchar](100) NULL,
	[AgencyFund] [nvarchar](10) NULL,
	[PassportNumber] [nvarchar](20) NULL,
	[PassportExpiry] [datetime2](7) NULL,
	[OtherIDType] [nvarchar](100) NULL,
	[OtherIDNumber] [nvarchar](100) NULL,
	[IDExpiryDate] [datetime2](7) NULL,
	[WorkPassType] [nvarchar](100) NULL,
	[WorkPassNumber] [nvarchar](20) NULL,
	[WorkPassDateofApplication] [datetime2](7) NULL,
	[WorkPassDateofIssue] [datetime2](7) NULL,
	[WorkPassDateofExpiry] [datetime2](7) NULL,
	[DateOfSPRGranted] [datetime2](7) NULL,
	[DateOfSPRExpiry] [datetime2](7) NULL,
	[NRICNumber] [nvarchar](100) NULL,
	[FIN] [nvarchar](100) NULL,
	[IsMandatoryTimeReport] [bit] NULL,
	[IsWorkflowOnly] [bit] NULL,
	[JobApplicationId] [uniqueidentifier] NULL,
	[IsHROnly] [bit] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[SyncEntityId] [uniqueidentifier] NULL,
	[SyncEntityStatus] [varchar](50) NULL,
	[SyncEntityDate] [datetime2](7) NULL,
	[SyncEntityRemarks] [nvarchar](max) NULL,
	[IsEmployee] [bit] NULL,
	[HighestQualification ] [nvarchar](2000) NULL,
	[WFMemberId] [nvarchar](50) NULL,
	[CurrentServiceEnittyId] [bigint] NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[DepartmentCode] [nvarchar](500) NULL,
	[DesignationCode] [nvarchar](500) NULL,
	[DepartmentName] [nvarchar](500) NULL,
	[DesignationName] [nvarchar](500) NULL,
	[AnnualPTDBalance] [float] NULL,
	[AnnualYTDBalance] [float] NULL,
	[SubscriptionId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Employee] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Employee] CHECK CONSTRAINT [FK_Employee_Company]
GO
ALTER TABLE [Common].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_MediaRepository] FOREIGN KEY([PhotoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[Employee] CHECK CONSTRAINT [FK_Employee_MediaRepository]
GO

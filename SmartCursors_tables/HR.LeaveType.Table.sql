USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveType]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveType](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[NoOfLeaves] [float] NULL,
	[IsShowToUser] [bit] NULL,
	[LeaveAccuralType] [nvarchar](30) NULL,
	[AccuralDays] [float] NULL,
	[IsCarryForward] [bit] NULL,
	[NoOfDays] [nvarchar](10) NULL,
	[IsAllowExcess] [bit] NULL,
	[EnableLeaveRecommender] [bit] NULL,
	[IsNoOfDays] [bit] NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[EntitlementType] [nvarchar](15) NULL,
	[EntitlementHours] [float] NULL,
	[ApplyToAll] [nvarchar](20) NULL,
	[AllowProbationPeriod] [bit] NULL,
	[IsCaseLeave] [bit] NULL,
	[IsMOM] [bit] NULL,
	[IsSystem] [bit] NULL,
	[IsNotSynctoWorkflow] [bit] NULL,
	[IsNotSynctoAttendance] [bit] NULL,
	[IsHideProrationLeaveDay] [bit] NULL,
	[DayInMonth] [int] NULL,
 CONSTRAINT [PK_LeaveType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveType] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveType]  WITH CHECK ADD  CONSTRAINT [FK_LeaveType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[LeaveType] CHECK CONSTRAINT [FK_LeaveType_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveEntitlement]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveEntitlement](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[IsApplicable] [bit] NULL,
	[AnnualLeaveEntitlement] [float] NULL,
	[LeaveApprovers] [nvarchar](500) NULL,
	[LeaveRecommenders] [nvarchar](500) NULL,
	[Prorated] [float] NULL,
	[ApprovedAndTaken] [float] NULL,
	[ApprovedAndNotTaken] [float] NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[BroughtForward] [float] NULL,
	[IsEnableLeaveRecommender] [bit] NULL,
	[Adjustment] [decimal](17, 2) NULL,
	[Adjusted] [decimal](17, 2) NULL,
	[CompletedMonth] [int] NULL,
	[RemainingProrated] [float] NULL,
	[IsNotRequiredRecommender] [bit] NULL,
	[IsNotRequiredApprover] [bit] NULL,
	[Total] [float] NULL,
	[Current] [float] NULL,
	[LeaveBalance] [float] NULL,
	[CarryForwardDays] [float] NULL,
	[SubmittedCount] [float] NULL,
	[RecommendCount] [float] NULL,
	[EntitlementStatus] [int] NULL,
	[TakenNotTakenDate] [datetime2](7) NULL,
	[YTDLeaveBalance] [float] NULL,
	[FutureProrated] [float] NULL,
	[HrSettingDetaiId] [uniqueidentifier] NULL,
	[IsMonthlyProration] [bit] NULL,
 CONSTRAINT [PK_LeaveEntitlement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveEntitlement] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveEntitlement] ADD  DEFAULT ((0)) FOR [IsEnableLeaveRecommender]
GO
ALTER TABLE [HR].[LeaveEntitlement]  WITH CHECK ADD  CONSTRAINT [FK_LeaveEntitlement_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveEntitlement] CHECK CONSTRAINT [FK_LeaveEntitlement_Employee]
GO
ALTER TABLE [HR].[LeaveEntitlement]  WITH CHECK ADD  CONSTRAINT [FK_LeaveEntitlement_LeaveTypeId] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeaveEntitlement] CHECK CONSTRAINT [FK_LeaveEntitlement_LeaveTypeId]
GO

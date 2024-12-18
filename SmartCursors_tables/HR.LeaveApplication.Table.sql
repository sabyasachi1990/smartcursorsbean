USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveApplication]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveApplication](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[LeaveTypeId] [uniqueidentifier] NOT NULL,
	[RecommenderId] [uniqueidentifier] NULL,
	[RecommenderName] [nvarchar](200) NULL,
	[ApproverId] [uniqueidentifier] NULL,
	[ApproverName] [nvarchar](200) NULL,
	[StartDateTime] [datetime2](7) NOT NULL,
	[EndDateTime] [datetime2](7) NOT NULL,
	[Days] [float] NULL,
	[IsAttachment] [bit] NULL,
	[LeaveStatus] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[LeaveBalance] [float] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Hours] [float] NULL,
	[StartDateType] [nvarchar](10) NULL,
	[EndDateType] [nvarchar](10) NULL,
	[LeaveApproverIds] [nvarchar](1000) NULL,
	[LeaveRecommenderIds] [nvarchar](1000) NULL,
	[RecommenderUserId] [bigint] NULL,
	[ApproverUserId] [bigint] NULL,
	[YTDLeaveBalance] [float] NULL,
	[OCalendarEventId] [nvarchar](500) NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[HRSettingDetailId] [uniqueidentifier] NULL,
	[LeaveApprovers] [nvarchar](500) NULL,
	[LeaveRecommenders] [nvarchar](500) NULL,
	[DepartmentName] [nvarchar](500) NULL,
	[DesignationName] [nvarchar](500) NULL,
	[ServiceEntityId] [bigint] NULL,
	[ClientId] [uniqueidentifier] NULL,
	[CaseId] [uniqueidentifier] NULL,
	[CaseNumber] [nvarchar](2000) NULL,
	[ClientName] [nvarchar](2000) NULL,
	[IsCaseLeave] [bit] NULL,
	[IsWorkFlowCursor] [bit] NULL,
	[IsTaken] [bit] NULL,
 CONSTRAINT [PK_LeaveApplication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveApplication] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveApplication]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplication_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[LeaveApplication] CHECK CONSTRAINT [FK_LeaveApplication_Company]
GO
ALTER TABLE [HR].[LeaveApplication]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplication_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveApplication] CHECK CONSTRAINT [FK_LeaveApplication_Employee]
GO
ALTER TABLE [HR].[LeaveApplication]  WITH CHECK ADD  CONSTRAINT [FK_LeaveApplication_LeaveType] FOREIGN KEY([LeaveTypeId])
REFERENCES [HR].[LeaveType] ([Id])
GO
ALTER TABLE [HR].[LeaveApplication] CHECK CONSTRAINT [FK_LeaveApplication_LeaveType]
GO

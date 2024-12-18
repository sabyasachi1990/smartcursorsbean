USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveRequest]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveRequest](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RequesterId] [uniqueidentifier] NOT NULL,
	[LeaveType] [nvarchar](100) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Days] [float] NULL,
	[Reason] [nvarchar](500) NULL,
	[ReportingManagerId] [uniqueidentifier] NULL,
	[RejectReason] [nvarchar](500) NULL,
	[IsAttachment] [bit] NULL,
	[LeaveStatus] [nvarchar](10) NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LeaveRequest] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveRequest] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[LeaveRequest] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveRequest]  WITH CHECK ADD  CONSTRAINT [FK_LeaveRequest_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[LeaveRequest] CHECK CONSTRAINT [FK_LeaveRequest_Company]
GO
ALTER TABLE [HR].[LeaveRequest]  WITH CHECK ADD  CONSTRAINT [FK_LeaveRequest_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[LeaveRequest] CHECK CONSTRAINT [FK_LeaveRequest_Employee]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Employment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Employment](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[TypeOfEmployment] [nvarchar](20) NULL,
	[Period] [nvarchar](15) NULL,
	[HireDate] [datetime2](7) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[IsReJoined] [datetime2](7) NULL,
	[ProbationPeriod] [nvarchar](15) NULL,
	[ConfirmationDate] [datetime2](7) NULL,
	[ConfirmationRemarks] [nvarchar](1000) NULL,
	[NoticePeriod] [nvarchar](15) NULL,
	[NoticePeriodEnd] [datetime2](7) NULL,
	[NoticePeriodRemarks] [nvarchar](max) NULL,
	[NoticePeriodStart] [datetime2](7) NULL,
	[RejoinedStatus] [nvarchar](30) NULL,
	[ReasonForLeaving] [nvarchar](1000) NULL,
	[EmployeeName] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsEmployeeRejoined] [bit] NULL,
 CONSTRAINT [PK_Employment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Employment] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Employment]  WITH CHECK ADD  CONSTRAINT [FK_Employment_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Employment] CHECK CONSTRAINT [FK_Employment_Company]
GO
ALTER TABLE [HR].[Employment]  WITH CHECK ADD  CONSTRAINT [FK_Employment_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Employment] CHECK CONSTRAINT [FK_Employment_Employee]
GO

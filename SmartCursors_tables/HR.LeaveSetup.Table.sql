USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveSetup]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveSetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[LeaveType] [nvarchar](30) NULL,
	[NoOfLeaves] [int] NULL,
	[Applicability] [nvarchar](30) NULL,
	[IsAllowCarryForward] [bit] NULL,
	[MaxCarryForward] [int] NULL,
	[AccuralBase] [nvarchar](10) NULL,
	[MandatorySupportingDocs] [bit] NULL,
	[IsAllowUnPaid] [bit] NULL,
	[IsAllowEncashment] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Comments] [nvarchar](500) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LeaveSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveSetup] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[LeaveSetup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[LeaveSetup]  WITH CHECK ADD  CONSTRAINT [FK_LeaveSetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[LeaveSetup] CHECK CONSTRAINT [FK_LeaveSetup_Company]
GO

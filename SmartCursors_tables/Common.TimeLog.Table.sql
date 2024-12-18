USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLog](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[TimeLogItemId] [uniqueidentifier] NULL,
	[Startdate] [datetime2](7) NULL,
	[Enddate] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[Version] [int] NULL,
	[Status] [int] NULL,
	[IsTimelogDisable] [bit] NULL,
 CONSTRAINT [PK_TimeLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLog] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TimeLog]  WITH CHECK ADD  CONSTRAINT [FK_TimeLog_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TimeLog] CHECK CONSTRAINT [FK_TimeLog_Company]
GO
ALTER TABLE [Common].[TimeLog]  WITH CHECK ADD  CONSTRAINT [FK_TimeLog_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[TimeLog] CHECK CONSTRAINT [FK_TimeLog_Employee]
GO
ALTER TABLE [Common].[TimeLog]  WITH CHECK ADD  CONSTRAINT [FK_TimeLog_TimeLogItem] FOREIGN KEY([TimeLogItemId])
REFERENCES [Common].[TimeLogItem] ([Id])
GO
ALTER TABLE [Common].[TimeLog] CHECK CONSTRAINT [FK_TimeLog_TimeLogItem]
GO

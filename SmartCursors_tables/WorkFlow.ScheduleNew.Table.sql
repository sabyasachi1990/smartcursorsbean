USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ScheduleNew]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ScheduleNew](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[JobDeadLine] [nvarchar](250) NULL,
	[IsEmail] [bit] NULL,
 CONSTRAINT [PK_ScheduleNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ScheduleNew] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ScheduleNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleNew_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleNew] CHECK CONSTRAINT [FK_ScheduleNew_CaseGroup]
GO
ALTER TABLE [WorkFlow].[ScheduleNew]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleNew_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[ScheduleNew] CHECK CONSTRAINT [FK_ScheduleNew_Company]
GO

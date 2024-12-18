USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Schedule]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Schedule](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[DateOfApproval] [datetime2](7) NULL,
	[StartDate] [datetime2](7) NULL,
	[CompletionDate] [datetime2](7) NULL,
	[Likelihood] [nvarchar](20) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Schedule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Schedule] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[Schedule] CHECK CONSTRAINT [FK_Schedule_CaseGroup]
GO
ALTER TABLE [WorkFlow].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[Schedule] CHECK CONSTRAINT [FK_Schedule_Company]
GO

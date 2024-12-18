USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseAmendDateOfCompletion]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseAmendDateOfCompletion](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[AmendDate] [datetime2](7) NULL,
	[Reason] [nvarchar](254) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_CaseAmendDateOfCompletion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseAmendDateOfCompletion] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseAmendDateOfCompletion]  WITH CHECK ADD  CONSTRAINT [FK_CaseAmendDateOfCompletion_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseAmendDateOfCompletion] CHECK CONSTRAINT [FK_CaseAmendDateOfCompletion_CaseGroup]
GO
ALTER TABLE [WorkFlow].[CaseAmendDateOfCompletion]  WITH CHECK ADD  CONSTRAINT [FK_CaseAmendDateOfCompletion_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseAmendDateOfCompletion] CHECK CONSTRAINT [FK_CaseAmendDateOfCompletion_Employee]
GO

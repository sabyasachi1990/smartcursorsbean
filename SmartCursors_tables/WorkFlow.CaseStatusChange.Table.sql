USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseStatusChange]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseStatusChange](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[State] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_CaseStatusChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_CaseStatusChange_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseStatusChange] CHECK CONSTRAINT [FK_CaseStatusChange_CaseGroup]
GO
ALTER TABLE [WorkFlow].[CaseStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_CaseStatusChange_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseStatusChange] CHECK CONSTRAINT [FK_CaseStatusChange_Company]
GO

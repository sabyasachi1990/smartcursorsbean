USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseDoc]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseDoc](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocId] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_CaseDoc] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseDoc] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseDoc]  WITH CHECK ADD  CONSTRAINT [FK_CaseDoc_Case] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [WorkFlow].[CaseDoc] CHECK CONSTRAINT [FK_CaseDoc_Case]
GO
ALTER TABLE [WorkFlow].[CaseDoc]  WITH CHECK ADD  CONSTRAINT [FK_CaseDoc_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseDoc] CHECK CONSTRAINT [FK_CaseDoc_Company]
GO
ALTER TABLE [WorkFlow].[CaseDoc]  WITH CHECK ADD  CONSTRAINT [FK_CaseDoc_MediaRepository] FOREIGN KEY([DocId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseDoc] CHECK CONSTRAINT [FK_CaseDoc_MediaRepository]
GO

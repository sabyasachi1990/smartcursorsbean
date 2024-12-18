USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[JournalHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[JournalHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[JournalId] [uniqueidentifier] NOT NULL,
	[OldDocState] [nvarchar](20) NOT NULL,
	[NewDocState] [nvarchar](20) NOT NULL,
	[ChangedDate] [datetime2](7) NULL,
	[ChangedBy] [nvarchar](254) NULL,
 CONSTRAINT [PK_JournalHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[JournalHistory]  WITH CHECK ADD  CONSTRAINT [FK_JournalHistory_Journal] FOREIGN KEY([JournalId])
REFERENCES [Bean].[Journal] ([Id])
GO
ALTER TABLE [Bean].[JournalHistory] CHECK CONSTRAINT [FK_JournalHistory_Journal]
GO

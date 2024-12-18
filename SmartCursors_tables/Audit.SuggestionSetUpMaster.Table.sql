USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[SuggestionSetUpMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[SuggestionSetUpMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[ScreenName] [nvarchar](256) NULL,
	[Section] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_SuggestionSetUpMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[SuggestionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_SuggestionSetUpMaster_AuditManual] FOREIGN KEY([AuditManualId])
REFERENCES [Audit].[AuditManual] ([Id])
GO
ALTER TABLE [Audit].[SuggestionSetUpMaster] CHECK CONSTRAINT [FK_SuggestionSetUpMaster_AuditManual]
GO
ALTER TABLE [Audit].[SuggestionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_SuggestionSetUpMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[SuggestionSetUpMaster] CHECK CONSTRAINT [FK_SuggestionSetUpMaster_Company]
GO

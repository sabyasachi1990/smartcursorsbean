USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TrialBalanceImportPreferences_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TrialBalanceImportPreferences_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[ImportMode] [nvarchar](50) NULL,
	[UnmatchedLeadSheets] [bit] NULL,
	[BalanceRounding] [bit] NULL,
	[RollForward] [bit] NULL,
	[Engagement] [nvarchar](50) NULL,
	[FileId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TrialBalanceImportPreferences] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

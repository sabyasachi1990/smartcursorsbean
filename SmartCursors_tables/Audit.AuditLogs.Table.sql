USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditLogs]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditLogs](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[Screen] [nvarchar](200) NULL,
	[Action] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](200) NULL,
	[DeveloperRemarks] [nvarchar](max) NULL,
	[Object] [nvarchar](max) NULL,
 CONSTRAINT [PK_AuditLogs_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

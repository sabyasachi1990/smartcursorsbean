USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[TimelogAuditLogs]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimelogAuditLogs](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Title] [nvarchar](255) NOT NULL,
	[Remarks] [nvarchar](2000) NULL,
	[Obj] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimelogAuditLogs] ADD  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[TimelogAuditLogs] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

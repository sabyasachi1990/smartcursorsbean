USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AMWorkProgramSetUp]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AMWorkProgramSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditManualName] [nvarchar](100) NULL,
	[WorkProgramName] [nvarchar](100) NULL,
 CONSTRAINT [PK_AMWorkProgramSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

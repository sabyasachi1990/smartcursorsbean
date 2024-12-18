USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[JobStatus]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[JobStatus](
	[Id] [uniqueidentifier] NOT NULL,
	[Module] [nvarchar](50) NULL,
	[Jobname] [nvarchar](256) NULL,
	[Type] [nvarchar](100) NULL,
	[Purpose] [nvarchar](100) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[RecordsEffeted] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[JobStatus] [nvarchar](100) NULL,
 CONSTRAINT [PK_JobStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

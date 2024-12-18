USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[TransactionDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[TransactionDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[ScreenName] [nvarchar](100) NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Status] [nvarchar](254) NULL,
	[TotalRecords] [int] NULL,
	[FailedRecords] [int] NULL,
	[SuccessedRecords] [int] NULL,
	[Remarks] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

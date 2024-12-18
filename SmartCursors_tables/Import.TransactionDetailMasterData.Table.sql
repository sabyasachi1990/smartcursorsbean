USE [SmartCursorSTG]
GO
/****** Object:  Table [Import].[TransactionDetailMasterData]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Import].[TransactionDetailMasterData](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[CompanyId] [int] NOT NULL,
	[ScreenName] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](1000) NULL,
	[Table] [nvarchar](100) NULL,
	[Type] [nvarchar](500) NULL,
	[Date] [datetime2](7) NULL
) ON [PRIMARY]
GO

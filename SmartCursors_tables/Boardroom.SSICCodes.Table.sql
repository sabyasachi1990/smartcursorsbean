USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[SSICCodes]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[SSICCodes](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](100) NOT NULL,
	[Industry] [nvarchar](4000) NOT NULL,
	[Status] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CompanyId] [bigint] NULL,
 CONSTRAINT [PK_SSICCodes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[BankNames]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[BankNames](
	[Id] [uniqueidentifier] NOT NULL,
	[Jurisdiction] [nvarchar](50) NOT NULL,
	[State] [nvarchar](100) NULL,
	[BankName] [nvarchar](200) NULL,
	[BankCode] [nvarchar](50) NULL,
	[MinAccNumLength] [int] NULL,
	[MaxAccNumLength] [int] NULL,
	[Remarks] [nvarchar](100) NULL,
 CONSTRAINT [PK_BankNames] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

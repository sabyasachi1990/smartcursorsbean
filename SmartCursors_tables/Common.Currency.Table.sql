USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Currency]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Currency](
	[Id] [bigint] NOT NULL,
	[Code] [nvarchar](5) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[DefaultValue] [nvarchar](20) NULL,
	[SDollerPerUnit] [int] NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

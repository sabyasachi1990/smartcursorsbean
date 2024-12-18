USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ExpressionDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ExpressionDetail](
	[Id] [bigint] NOT NULL,
	[MasterId] [bigint] NOT NULL,
	[Comment] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](128) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ExpressionDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

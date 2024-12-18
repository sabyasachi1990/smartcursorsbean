USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Order]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Order](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[LeadSheetType] [nvarchar](50) NULL,
	[AccountClass] [nvarchar](50) NULL,
	[Recorder] [nvarchar](max) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

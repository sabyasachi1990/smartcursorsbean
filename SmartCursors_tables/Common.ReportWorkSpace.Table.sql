USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ReportWorkSpace]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ReportWorkSpace](
	[Id] [uniqueidentifier] NOT NULL,
	[WorkSpaceId] [uniqueidentifier] NOT NULL,
	[Environment] [nvarchar](10) NULL,
	[WorkSpaceName] [nvarchar](100) NULL,
 CONSTRAINT [PK_ReportWorkSpace] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

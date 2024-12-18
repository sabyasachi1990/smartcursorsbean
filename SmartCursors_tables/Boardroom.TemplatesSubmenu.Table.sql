USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[TemplatesSubmenu]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[TemplatesSubmenu](
	[Id] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](300) NOT NULL,
	[SubType] [nvarchar](300) NOT NULL,
 CONSTRAINT [TemplatesSubmenu_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

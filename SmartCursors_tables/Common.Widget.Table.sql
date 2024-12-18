USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Widget]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Widget](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Roles] [nvarchar](256) NOT NULL,
	[RoutingPath] [nvarchar](1000) NULL,
	[Content] [nvarchar](max) NOT NULL,
	[Rank] [int] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Widget] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Widget] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Widget]  WITH CHECK ADD  CONSTRAINT [FK_Widget_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Widget] CHECK CONSTRAINT [FK_Widget_Company]
GO

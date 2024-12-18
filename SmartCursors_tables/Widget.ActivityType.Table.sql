USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityType]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityType](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[NameFormat] [nvarchar](100) NULL,
	[CompanyId] [bigint] NOT NULL,
	[Icon] [nvarchar](3000) NULL,
	[IconClass] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityType]  WITH CHECK ADD  CONSTRAINT [FK_ActivityType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[ActivityType] CHECK CONSTRAINT [FK_ActivityType_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[TodoMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[TodoMaster](
	[Id] [bigint] NOT NULL,
	[UrlContext] [nvarchar](1000) NOT NULL,
	[HashTag] [nvarchar](256) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Icon] [nvarchar](2000) NULL,
	[Heading] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TodoMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[TodoMaster] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[TodoMaster]  WITH CHECK ADD  CONSTRAINT [FK_TodoMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[TodoMaster] CHECK CONSTRAINT [FK_TodoMaster_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[Permission]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[Permission](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FontAwesomeClass] [nvarchar](50) NOT NULL,
	[IsFunctionOnly] [bit] NULL,
	[RecOrder] [int] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[IsDisable] [bit] NULL,
 CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[Permission] ADD  DEFAULT ((0)) FOR [IsFunctionOnly]
GO
ALTER TABLE [Auth].[Permission] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Auth].[Permission]  WITH CHECK ADD  CONSTRAINT [FK_Permission_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Auth].[Permission] CHECK CONSTRAINT [FK_Permission_Company]
GO

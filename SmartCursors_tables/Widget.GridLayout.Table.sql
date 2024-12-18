USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[GridLayout]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[GridLayout](
	[Id] [bigint] NOT NULL,
	[UrlContext] [nvarchar](1000) NOT NULL,
	[Username] [nvarchar](256) NOT NULL,
	[Parameter] [nvarchar](1000) NULL,
	[HashTag] [nvarchar](256) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[GridView] [nvarchar](max) NOT NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](128) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](128) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_GridLayout] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Widget].[GridLayout] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[GridLayout]  WITH CHECK ADD  CONSTRAINT [FK_GridLayout_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[GridLayout] CHECK CONSTRAINT [FK_GridLayout_Company]
GO

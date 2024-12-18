USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AutoNumberDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AutoNumberDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[EntityType] [nvarchar](100) NOT NULL,
	[Format] [nvarchar](100) NULL,
	[GeneratedNumber] [nvarchar](50) NULL,
	[CounterLength] [int] NULL,
	[MaxLength] [int] NULL,
	[Reset] [nvarchar](20) NULL,
	[Preview] [nvarchar](50) NULL,
 CONSTRAINT [PK_AutoNumberDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AutoNumberDetail]  WITH CHECK ADD  CONSTRAINT [FK_AutoNumberDetail_Company] FOREIGN KEY([MasterId])
REFERENCES [Common].[AutoNumber] ([Id])
GO
ALTER TABLE [Common].[AutoNumberDetail] CHECK CONSTRAINT [FK_AutoNumberDetail_Company]
GO

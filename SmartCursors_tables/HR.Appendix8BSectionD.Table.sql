USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8BSectionD]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8BSectionD](
	[Id] [uniqueidentifier] NOT NULL,
	[Appendix8BId] [uniqueidentifier] NOT NULL,
	[SecDa] [nvarchar](1000) NULL,
	[SecDb] [nvarchar](1000) NULL,
	[SecDc1] [nvarchar](500) NULL,
	[SecDc2] [datetime2](7) NULL,
	[SecDd] [datetime2](7) NULL,
	[SecDe] [money] NULL,
	[SecDf] [nvarchar](500) NULL,
	[SecDg] [nvarchar](500) NULL,
	[SecDh] [nvarchar](1000) NULL,
	[SecDk] [nvarchar](500) NULL,
	[SecDI] [nvarchar](500) NULL,
	[SecDm] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_Appendix8BSectionD] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8BSectionD]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8BSectionD_Appendix8B] FOREIGN KEY([Appendix8BId])
REFERENCES [HR].[Appendix8B] ([Id])
GO
ALTER TABLE [HR].[Appendix8BSectionD] CHECK CONSTRAINT [FK_Appendix8BSectionD_Appendix8B]
GO

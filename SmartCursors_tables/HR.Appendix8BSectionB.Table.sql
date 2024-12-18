USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8BSectionB]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8BSectionB](
	[Id] [uniqueidentifier] NOT NULL,
	[Appendix8BId] [uniqueidentifier] NOT NULL,
	[SecBa] [nvarchar](1000) NULL,
	[SecBb] [nvarchar](1000) NULL,
	[SecBc1] [nvarchar](500) NULL,
	[SecBc2] [datetime2](7) NULL,
	[SecBd] [datetime2](7) NULL,
	[SecBe] [money] NULL,
	[SecBf] [nvarchar](500) NULL,
	[SecBg] [nvarchar](500) NULL,
	[SecBh] [nvarchar](1000) NULL,
	[SecBi] [nvarchar](500) NULL,
	[SecB-I] [nvarchar](500) NULL,
	[SecBm] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_Appendix8BSectionB] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8BSectionB]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8BSectionB_Appendix8B] FOREIGN KEY([Appendix8BId])
REFERENCES [HR].[Appendix8B] ([Id])
GO
ALTER TABLE [HR].[Appendix8BSectionB] CHECK CONSTRAINT [FK_Appendix8BSectionB_Appendix8B]
GO

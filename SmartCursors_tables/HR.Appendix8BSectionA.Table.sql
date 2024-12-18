USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8BSectionA]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8BSectionA](
	[Id] [uniqueidentifier] NOT NULL,
	[Appendix8BId] [uniqueidentifier] NOT NULL,
	[SecAa] [nvarchar](1000) NULL,
	[SecAb] [nvarchar](1000) NULL,
	[SecAc1] [nvarchar](500) NULL,
	[SecAc2] [datetime2](7) NULL,
	[SecAd] [datetime2](7) NULL,
	[SecAe] [money] NULL,
	[SecAg] [nvarchar](500) NULL,
	[SecAh] [nvarchar](500) NULL,
	[SecAI] [nvarchar](500) NULL,
	[SecAm] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_Appendix8BSectionA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8BSectionA]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8BSectionA_Appendix8B] FOREIGN KEY([Appendix8BId])
REFERENCES [HR].[Appendix8B] ([Id])
GO
ALTER TABLE [HR].[Appendix8BSectionA] CHECK CONSTRAINT [FK_Appendix8BSectionA_Appendix8B]
GO

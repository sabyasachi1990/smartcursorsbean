USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8BSectionC]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8BSectionC](
	[Id] [uniqueidentifier] NOT NULL,
	[Appendix8BId] [uniqueidentifier] NOT NULL,
	[SecCa] [nvarchar](1000) NULL,
	[SecCb] [nvarchar](1000) NULL,
	[SecCc1] [nvarchar](500) NULL,
	[SecCc2] [datetime2](7) NULL,
	[SecCd] [datetime2](7) NULL,
	[SecCe] [money] NULL,
	[SecCf] [nvarchar](500) NULL,
	[SecCg] [nvarchar](500) NULL,
	[SecCh] [nvarchar](1000) NULL,
	[SecCj] [nvarchar](500) NULL,
	[SecCI] [nvarchar](500) NULL,
	[SecCm] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_Appendix8BSectionC] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8BSectionC]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8BSectionC_Appendix8B] FOREIGN KEY([Appendix8BId])
REFERENCES [HR].[Appendix8B] ([Id])
GO
ALTER TABLE [HR].[Appendix8BSectionC] CHECK CONSTRAINT [FK_Appendix8BSectionC_Appendix8B]
GO

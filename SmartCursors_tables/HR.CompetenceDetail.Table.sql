USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[CompetenceDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[CompetenceDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_CompetenceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[CompetenceDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompetenceDetail_Competence] FOREIGN KEY([MasterId])
REFERENCES [HR].[Competence] ([Id])
GO
ALTER TABLE [HR].[CompetenceDetail] CHECK CONSTRAINT [FK_CompetenceDetail_Competence]
GO

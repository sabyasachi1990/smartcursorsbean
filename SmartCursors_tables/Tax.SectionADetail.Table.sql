USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[SectionADetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[SectionADetail](
	[Id] [uniqueidentifier] NOT NULL,
	[SECTIONAId] [uniqueidentifier] NOT NULL,
	[YearOfAccessment] [int] NULL,
	[PrincipalPaid] [decimal](17, 2) NULL,
	[Recorder] [int] NULL,
	[RevisedPrincipalPaid] [decimal](17, 0) NULL,
 CONSTRAINT [PK_SECTIONADetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[SectionADetail]  WITH CHECK ADD  CONSTRAINT [FK_SECTIONADetail_SectionA] FOREIGN KEY([SECTIONAId])
REFERENCES [Tax].[SectionA] ([Id])
GO
ALTER TABLE [Tax].[SectionADetail] CHECK CONSTRAINT [FK_SECTIONADetail_SectionA]
GO

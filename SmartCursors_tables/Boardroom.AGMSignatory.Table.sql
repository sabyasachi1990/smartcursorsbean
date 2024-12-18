USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMSignatory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMSignatory](
	[Id] [uniqueidentifier] NOT NULL,
	[AGMDetailId] [uniqueidentifier] NOT NULL,
	[GenericContactId] [uniqueidentifier] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Position] [nvarchar](100) NOT NULL,
	[Signatory] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_AGMSignatory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMSignatory]  WITH CHECK ADD  CONSTRAINT [FK_AGMSignatory_GenericContact] FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[AGMSignatory] CHECK CONSTRAINT [FK_AGMSignatory_GenericContact]
GO

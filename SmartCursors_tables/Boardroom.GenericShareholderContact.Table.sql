USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[GenericShareholderContact]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[GenericShareholderContact](
	[Id] [uniqueidentifier] NOT NULL,
	[GenericContactId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[Name] [nvarchar](254) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_GenericShareholderContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[GenericShareholderContact]  WITH CHECK ADD  CONSTRAINT [FK_GenericShareholderContact_GenericContact] FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[GenericShareholderContact] CHECK CONSTRAINT [FK_GenericShareholderContact_GenericContact]
GO

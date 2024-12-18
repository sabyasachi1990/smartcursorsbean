USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Signatory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Signatory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](15) NOT NULL,
	[Signatory] [nvarchar](20) NOT NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Signatory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Signatory]  WITH CHECK ADD  CONSTRAINT [FK_Signatory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Signatory] CHECK CONSTRAINT [FK_Signatory_Company]
GO
ALTER TABLE [Boardroom].[Signatory]  WITH CHECK ADD  CONSTRAINT [FK_Signatory_Entity] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Signatory] CHECK CONSTRAINT [FK_Signatory_Entity]
GO
ALTER TABLE [Boardroom].[Signatory]  WITH CHECK ADD  CONSTRAINT [FK_Signatory_GenericContact] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[Signatory] CHECK CONSTRAINT [FK_Signatory_GenericContact]
GO

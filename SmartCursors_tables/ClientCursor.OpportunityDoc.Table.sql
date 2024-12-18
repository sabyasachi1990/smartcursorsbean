USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityDoc]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityDoc](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](254) NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocId] [uniqueidentifier] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_OpportunityDoc] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityDoc] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[OpportunityDoc]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityDoc_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityDoc] CHECK CONSTRAINT [FK_OpportunityDoc_Company]
GO
ALTER TABLE [ClientCursor].[OpportunityDoc]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityDoc_MediaRepository] FOREIGN KEY([DocId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityDoc] CHECK CONSTRAINT [FK_OpportunityDoc_MediaRepository]
GO
ALTER TABLE [ClientCursor].[OpportunityDoc]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityDoc_Oppurtunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityDoc] CHECK CONSTRAINT [FK_OpportunityDoc_Oppurtunity]
GO

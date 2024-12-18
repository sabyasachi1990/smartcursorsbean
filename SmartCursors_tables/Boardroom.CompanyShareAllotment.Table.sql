USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[CompanyShareAllotment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[CompanyShareAllotment](
	[Id] [uniqueidentifier] NOT NULL,
	[SharesId] [uniqueidentifier] NOT NULL,
	[IsSubClass] [bit] NULL,
	[Class] [nvarchar](3) NULL,
	[Ordinory] [decimal](10, 2) NULL,
	[Preference] [decimal](10, 2) NULL,
	[Others] [decimal](10, 2) NULL,
	[RecOrder] [int] NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CompanyShareAllotment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[CompanyShareAllotment] ADD  DEFAULT ((0)) FOR [IsSubClass]
GO
ALTER TABLE [Boardroom].[CompanyShareAllotment]  WITH CHECK ADD  CONSTRAINT [FK_CompanyShareAllotment_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[CompanyShareAllotment] CHECK CONSTRAINT [FK_CompanyShareAllotment_EntityDetail]
GO
ALTER TABLE [Boardroom].[CompanyShareAllotment]  WITH CHECK ADD  CONSTRAINT [FK_CompanyShareAllotment_Shares] FOREIGN KEY([SharesId])
REFERENCES [Boardroom].[Shares] ([Id])
GO
ALTER TABLE [Boardroom].[CompanyShareAllotment] CHECK CONSTRAINT [FK_CompanyShareAllotment_Shares]
GO

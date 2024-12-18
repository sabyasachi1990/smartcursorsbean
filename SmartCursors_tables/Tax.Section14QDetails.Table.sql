USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Section14QDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Section14QDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[Section14QId] [uniqueidentifier] NOT NULL,
	[YAOfPurchase] [int] NULL,
	[OutStandingTaxLife] [int] NULL,
	[OpeningBalance] [decimal](15, 0) NULL,
	[Additions] [decimal](15, 0) NULL,
	[WriteOff] [decimal](15, 0) NULL,
	[CurrentClaim] [decimal](15, 0) NULL,
	[ClosingBalance] [decimal](15, 0) NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_Section14QDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Section14QDetails]  WITH CHECK ADD  CONSTRAINT [FK_Section14Q_Section14QDetails] FOREIGN KEY([Section14QId])
REFERENCES [Tax].[Section14Q] ([Id])
GO
ALTER TABLE [Tax].[Section14QDetails] CHECK CONSTRAINT [FK_Section14Q_Section14QDetails]
GO

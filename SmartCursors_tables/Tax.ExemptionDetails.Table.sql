USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ExemptionDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ExemptionDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[ExemptionId] [uniqueidentifier] NULL,
	[FromValue] [decimal](20, 0) NULL,
	[ToValue] [decimal](20, 0) NULL,
	[ExemptedRate] [decimal](15, 2) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_ExemptionDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ExemptionDetails]  WITH CHECK ADD  CONSTRAINT [PK_ExemptionDetails_Exemption] FOREIGN KEY([ExemptionId])
REFERENCES [Tax].[Exemption] ([Id])
GO
ALTER TABLE [Tax].[ExemptionDetails] CHECK CONSTRAINT [PK_ExemptionDetails_Exemption]
GO

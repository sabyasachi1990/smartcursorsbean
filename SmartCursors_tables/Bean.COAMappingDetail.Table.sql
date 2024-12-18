USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[COAMappingDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[COAMappingDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[COAMappingId] [uniqueidentifier] NULL,
	[CustCOAId] [bigint] NOT NULL,
	[VenCOAId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[COAMappingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_COAMapping_ChartOfAccount_CustCOAId] FOREIGN KEY([CustCOAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[COAMappingDetail] CHECK CONSTRAINT [Bean_COAMapping_ChartOfAccount_CustCOAId]
GO
ALTER TABLE [Bean].[COAMappingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_COAMapping_ChartOfAccount_VenCOAId] FOREIGN KEY([VenCOAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[COAMappingDetail] CHECK CONSTRAINT [Bean_COAMapping_ChartOfAccount_VenCOAId]
GO

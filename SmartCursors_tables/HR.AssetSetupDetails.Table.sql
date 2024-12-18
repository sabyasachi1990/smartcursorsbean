USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AssetSetupDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AssetSetupDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[AssetSetupId] [uniqueidentifier] NOT NULL,
	[ItemNumber] [nvarchar](50) NULL,
	[Frequency] [bit] NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[ItemDescription] [varchar](250) NULL,
	[PurchaseDate] [datetime2](7) NULL,
 CONSTRAINT [PK_AssetSetupDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AssetSetupDetails]  WITH CHECK ADD  CONSTRAINT [FK_AssetSetupDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AssetSetupDetails] CHECK CONSTRAINT [FK_AssetSetupDetails_Employee]
GO
ALTER TABLE [HR].[AssetSetupDetails]  WITH CHECK ADD  CONSTRAINT [PK_AssetSetupDetails_AssetSetup] FOREIGN KEY([AssetSetupId])
REFERENCES [HR].[AssetSetup] ([Id])
GO
ALTER TABLE [HR].[AssetSetupDetails] CHECK CONSTRAINT [PK_AssetSetupDetails_AssetSetup]
GO

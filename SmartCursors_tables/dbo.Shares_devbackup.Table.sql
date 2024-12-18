USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[Shares_devbackup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shares_devbackup](
	[Registration No] [nvarchar](255) NULL,
	[Entity Name] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Position] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Transaction Date] [datetime] NULL,
	[Transaction Type] [nvarchar](255) NULL,
	[Currency] [nvarchar](255) NULL,
	[ShareDescription] [nvarchar](255) NULL,
	[ShareType] [nvarchar](255) NULL,
	[ShareClass] [nvarchar](255) NULL,
	[NumberOfShares] [float] NULL,
	[Issued] [float] NULL,
	[Paid Up] [float] NULL,
	[CertificateType] [nvarchar](255) NULL,
	[PaidUpValue] [float] NULL,
	[Price per Share] [float] NULL,
	[Certificate No] [float] NULL,
	[ID no] [nvarchar](255) NULL,
	[ID Type] [nvarchar](255) NULL
) ON [PRIMARY]
GO

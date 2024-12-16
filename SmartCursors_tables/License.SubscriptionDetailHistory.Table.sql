USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[SubscriptionDetailHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[SubscriptionDetailHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[Quantity] [int] NULL,
	[Price] [money] NULL,
	[PartnerPrice] [money] NULL,
	[ValidityPeriodFrom] [datetime2](7) NULL,
	[ValidityPeriodTo] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Escrow] [int] NULL,
 CONSTRAINT [PK_SubscriptionDetailHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

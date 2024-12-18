USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Forex]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Forex](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](20) NOT NULL,
	[DateFrom] [datetime2](7) NOT NULL,
	[Dateto] [datetime2](7) NOT NULL,
	[Currency] [nvarchar](10) NOT NULL,
	[UnitPerUSD] [decimal](15, 10) NOT NULL,
	[USDPerUnit] [decimal](15, 10) NOT NULL,
	[Notes] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[UnitPerCal] [decimal](15, 10) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Forex] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bean].[Forex] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Forex]  WITH CHECK ADD  CONSTRAINT [FK_Forex_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Forex] CHECK CONSTRAINT [FK_Forex_Company]
GO

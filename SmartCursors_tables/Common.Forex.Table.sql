USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Forex]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Forex](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Source] [nvarchar](50) NULL,
	[DateFrom] [datetime2](7) NULL,
	[Dateto] [datetime2](7) NULL,
	[FromCurrency] [nvarchar](10) NULL,
	[ToCurrency] [nvarchar](10) NULL,
	[FromForexRate] [decimal](15, 10) NULL,
	[ToForexRate] [decimal](15, 10) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [timestamp] NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Forex]  WITH CHECK ADD  CONSTRAINT [Common_Forex_Company_Id] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Forex] CHECK CONSTRAINT [Common_Forex_Company_Id]
GO

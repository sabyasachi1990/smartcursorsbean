USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[MultiCurrencySetting]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[MultiCurrencySetting](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[BaseCurrency] [nvarchar](50) NULL,
	[Revaluation] [bit] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_MultiCurrencySetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[MultiCurrencySetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[MultiCurrencySetting]  WITH CHECK ADD  CONSTRAINT [FK_MultiCurrencySetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[MultiCurrencySetting] CHECK CONSTRAINT [FK_MultiCurrencySetting_Company]
GO

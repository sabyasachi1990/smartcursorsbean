USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyGlobalSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyGlobalSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[BaseCurrency] [nvarchar](25) NULL,
	[LongdateFormat] [nvarchar](25) NULL,
	[ShortDateFormat] [nvarchar](25) NULL,
	[FirstDayOfWeek] [int] NULL,
	[Culture] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
 CONSTRAINT [PK_CompanyGlobalSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyGlobalSettings]  WITH CHECK ADD  CONSTRAINT [PK_CompanyGlobalSettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyGlobalSettings] CHECK CONSTRAINT [PK_CompanyGlobalSettings_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Localization]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Localization](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[LongDateFormat] [nvarchar](50) NULL,
	[ShortDateFormat] [nvarchar](50) NULL,
	[TimeFormat] [nvarchar](50) NULL,
	[BaseCurrency] [nvarchar](5) NULL,
	[BusinessYearEnd] [nvarchar](20) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[TimeZone] [nvarchar](100) NULL,
	[DefaultWorkingHours] [decimal](17, 2) NULL,
 CONSTRAINT [PK_Localization] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Localization] ADD  DEFAULT ((1)) FOR [Status]
GO

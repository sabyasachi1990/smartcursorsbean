USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GSTSetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GSTSetting](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Number] [nvarchar](50) NOT NULL,
	[DateOfRegistration] [datetime2](7) NULL,
	[DeRegistration] [datetime2](7) NULL,
	[IsDeregistered] [bit] NULL,
	[ReportingYearEnd] [nvarchar](30) NULL,
	[ReportingInterval] [nvarchar](20) NOT NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[GSTRepoCurrency] [nvarchar](50) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[GstYearEnd] [nvarchar](40) NULL,
 CONSTRAINT [PK_GSTSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[GSTSetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[GSTSetting]  WITH CHECK ADD  CONSTRAINT [FK_GSTSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[GSTSetting] CHECK CONSTRAINT [FK_GSTSetting_Company]
GO

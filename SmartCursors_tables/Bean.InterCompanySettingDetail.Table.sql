USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[InterCompanySettingDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[InterCompanySettingDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[InterCompanySettingId] [uniqueidentifier] NOT NULL,
	[ServiceEntityId] [bigint] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[InterCompanySettingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_InterCompanySettingDetail_Company_Id] FOREIGN KEY([ServiceEntityId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[InterCompanySettingDetail] CHECK CONSTRAINT [Bean_InterCompanySettingDetail_Company_Id]
GO
ALTER TABLE [Bean].[InterCompanySettingDetail]  WITH CHECK ADD  CONSTRAINT [Bean_InterCompanySettingDetail_InterCompanySetting_Id] FOREIGN KEY([InterCompanySettingId])
REFERENCES [Bean].[InterCompanySetting] ([Id])
GO
ALTER TABLE [Bean].[InterCompanySettingDetail] CHECK CONSTRAINT [Bean_InterCompanySettingDetail_InterCompanySetting_Id]
GO

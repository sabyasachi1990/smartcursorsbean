USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AGMSetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AGMSetting](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[BasedOn] [nvarchar](100) NOT NULL,
	[Year] [nvarchar](254) NOT NULL,
	[Formula] [nvarchar](254) NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
	[DocId] [uniqueidentifier] NOT NULL,
	[Period] [nvarchar](15) NULL,
	[NoOfDays] [nvarchar](15) NULL,
	[Duration] [nvarchar](15) NULL,
 CONSTRAINT [PK_AGMSetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AGMSetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[AGMSetting]  WITH CHECK ADD  CONSTRAINT [FK_AGMSetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[AGMSetting] CHECK CONSTRAINT [FK_AGMSetting_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanySetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanySetting](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CursorName] [nvarchar](100) NULL,
	[ModuleName] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_CompanySettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanySetting] ADD  DEFAULT ((0)) FOR [IsEnabled]
GO
ALTER TABLE [Common].[CompanySetting]  WITH CHECK ADD  CONSTRAINT [FK_CompanySettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanySetting] CHECK CONSTRAINT [FK_CompanySettings_Company]
GO

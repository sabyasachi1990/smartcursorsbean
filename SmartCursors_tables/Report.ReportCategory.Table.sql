USE [SmartCursorSTG]
GO
/****** Object:  Table [Report].[ReportCategory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[ReportCategory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[SpriteName] [nvarchar](100) NULL,
	[TabNames] [nvarchar](1024) NOT NULL,
	[ModuleName] [nvarchar](100) NOT NULL,
	[RecOrder] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[TempReportCategoryId] [uniqueidentifier] NULL,
	[PermissionKeys] [nvarchar](254) NULL,
	[CockpitPermissionKeys] [nvarchar](254) NULL,
 CONSTRAINT [PK_ReportCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Report].[ReportCategory]  WITH CHECK ADD  CONSTRAINT [FK_ReportCategory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Report].[ReportCategory] CHECK CONSTRAINT [FK_ReportCategory_Company]
GO

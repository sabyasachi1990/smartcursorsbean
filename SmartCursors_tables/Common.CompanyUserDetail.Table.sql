USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyUserDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyUserDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[ServiceEntityId] [bigint] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_CompanyUserDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyUserDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUserDetail_Company] FOREIGN KEY([ServiceEntityId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyUserDetail] CHECK CONSTRAINT [FK_CompanyUserDetail_Company]
GO
ALTER TABLE [Common].[CompanyUserDetail]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUserDetail_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [Common].[CompanyUserDetail] CHECK CONSTRAINT [FK_CompanyUserDetail_CompanyUser]
GO

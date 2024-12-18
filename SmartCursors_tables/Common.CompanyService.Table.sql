USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyService]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyService](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ServiceId] [bigint] NOT NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_CompanyService] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyService] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyService]  WITH CHECK ADD  CONSTRAINT [FK_CompanyService_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyService] CHECK CONSTRAINT [FK_CompanyService_Company]
GO
ALTER TABLE [Common].[CompanyService]  WITH CHECK ADD  CONSTRAINT [FK_CompanyService_ServiceGroup] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[CompanyService] CHECK CONSTRAINT [FK_CompanyService_ServiceGroup]
GO

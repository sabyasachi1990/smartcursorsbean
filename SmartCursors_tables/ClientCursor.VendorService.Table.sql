USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[VendorService]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[VendorService](
	[Id] [uniqueidentifier] NOT NULL,
	[VendorId] [uniqueidentifier] NOT NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_VendorService] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[VendorService] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[VendorService]  WITH CHECK ADD  CONSTRAINT [FK_VendorService_Account] FOREIGN KEY([VendorId])
REFERENCES [ClientCursor].[Vendor] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorService] CHECK CONSTRAINT [FK_VendorService_Account]
GO
ALTER TABLE [ClientCursor].[VendorService]  WITH CHECK ADD  CONSTRAINT [FK_VendorService_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorService] CHECK CONSTRAINT [FK_VendorService_ServiceGroup]
GO

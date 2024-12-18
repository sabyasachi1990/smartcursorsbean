USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[VendorTypeVendor]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[VendorTypeVendor](
	[Id] [uniqueidentifier] NOT NULL,
	[VendorId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[VendorTypeName] [nvarchar](25) NULL,
 CONSTRAINT [PK_VendorTypeVendor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[VendorTypeVendor] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[VendorTypeVendor]  WITH CHECK ADD  CONSTRAINT [FK_VendorTypeVendor_Account] FOREIGN KEY([VendorId])
REFERENCES [ClientCursor].[Vendor] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorTypeVendor] CHECK CONSTRAINT [FK_VendorTypeVendor_Account]
GO

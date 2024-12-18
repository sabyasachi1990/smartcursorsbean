USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[VendorContact]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[VendorContact](
	[Id] [uniqueidentifier] NOT NULL,
	[VendorId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](50) NULL,
	[Communication] [nvarchar](1000) NULL,
	[Matters] [nvarchar](1000) NULL,
	[Website] [nvarchar](1000) NULL,
	[IsPrimaryContact] [bit] NULL,
	[IsReminderReceipient] [bit] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_VendorContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[VendorContact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[VendorContact]  WITH CHECK ADD  CONSTRAINT [FK_VendorContact_Account] FOREIGN KEY([VendorId])
REFERENCES [ClientCursor].[Vendor] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorContact] CHECK CONSTRAINT [FK_VendorContact_Account]
GO
ALTER TABLE [ClientCursor].[VendorContact]  WITH CHECK ADD  CONSTRAINT [FK_VendorContact_Contact] FOREIGN KEY([ContactId])
REFERENCES [Common].[Contact] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorContact] CHECK CONSTRAINT [FK_VendorContact_Contact]
GO

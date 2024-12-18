USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[VendorNote]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[VendorNote](
	[Id] [uniqueidentifier] NOT NULL,
	[VendorId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Note] [nvarchar](2000) NOT NULL,
	[Rating] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_VendorNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[VendorNote] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[VendorNote]  WITH CHECK ADD  CONSTRAINT [FK_VendorNote_UserAccount] FOREIGN KEY([UserId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorNote] CHECK CONSTRAINT [FK_VendorNote_UserAccount]
GO
ALTER TABLE [ClientCursor].[VendorNote]  WITH CHECK ADD  CONSTRAINT [FK_VendorNote_Vendor] FOREIGN KEY([VendorId])
REFERENCES [ClientCursor].[Vendor] ([Id])
GO
ALTER TABLE [ClientCursor].[VendorNote] CHECK CONSTRAINT [FK_VendorNote_Vendor]
GO

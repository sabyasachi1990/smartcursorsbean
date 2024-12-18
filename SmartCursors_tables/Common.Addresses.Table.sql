USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Addresses]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Addresses](
	[Id] [uniqueidentifier] NOT NULL,
	[AddSectionType] [nvarchar](50) NOT NULL,
	[AddType] [nvarchar](300) NULL,
	[AddTypeId] [uniqueidentifier] NULL,
	[AddTypeIdInt] [bigint] NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[Status] [int] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[ScreenName] [nvarchar](50) NULL,
	[IsCurrentAddress] [bit] NULL,
	[CompanyId] [bigint] NULL,
	[CopyId] [uniqueidentifier] NULL,
	[RelationId] [uniqueidentifier] NULL,
 CONSTRAINT [Pk_Addresses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Addresses] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_Addresses_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [Common].[Addresses] CHECK CONSTRAINT [FK_Addresses_AddressBook]
GO
ALTER TABLE [Common].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_Addresses_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Addresses] CHECK CONSTRAINT [FK_Addresses_Company]
GO
ALTER TABLE [Common].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_Addresses_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Common].[Addresses] CHECK CONSTRAINT [FK_Addresses_EntityDetail]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Contact]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Contact](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Salutation] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NULL,
	[PhotoId] [uniqueidentifier] NULL,
	[DOB] [datetime2](7) NULL,
	[IdType] [nvarchar](25) NULL,
	[IdNo] [nvarchar](100) NULL,
	[CountryOfResidence] [nvarchar](100) NULL,
	[MailingAddressBookId] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [Pk_Contact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Contact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[Contact] CHECK CONSTRAINT [FK_Contact_Company]
GO
ALTER TABLE [WorkFlow].[Contact]  WITH CHECK ADD  CONSTRAINT [FK_Contact_MediaRepository] FOREIGN KEY([PhotoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [WorkFlow].[Contact] CHECK CONSTRAINT [FK_Contact_MediaRepository]
GO

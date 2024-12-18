USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[UserAccount]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[UserAccount](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime2](7) NULL,
	[Username] [nvarchar](254) NOT NULL,
	[Email] [nvarchar](254) NULL,
	[PhotoId] [uniqueidentifier] NULL,
	[Status] [int] NULL,
	[Title] [nvarchar](10) NULL,
	[Gender] [nvarchar](10) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[DeactivationDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[Role] [nvarchar](254) NULL,
	[Communication] [nvarchar](1000) NULL,
	[ViewType] [nvarchar](500) NULL,
	[Personalization] [varchar](max) NULL,
	[Password] [nvarchar](200) NULL,
	[ExternalSync] [nvarchar](64) NULL,
 CONSTRAINT [PK_UserAccount] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Auth].[UserAccount] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Auth].[UserAccount]  WITH CHECK ADD  CONSTRAINT [FK_UserAccount_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [Auth].[UserAccount] CHECK CONSTRAINT [FK_UserAccount_AddressBook]
GO
ALTER TABLE [Auth].[UserAccount]  WITH CHECK ADD  CONSTRAINT [FK_UserAccount_MediaRepository] FOREIGN KEY([PhotoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Auth].[UserAccount] CHECK CONSTRAINT [FK_UserAccount_MediaRepository]
GO

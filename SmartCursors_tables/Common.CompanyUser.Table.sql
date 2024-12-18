USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyUser]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyUser](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Username] [nvarchar](254) NOT NULL,
	[FirstName] [nvarchar](128) NULL,
	[LastName] [nvarchar](100) NULL,
	[IsPrimary] [bit] NULL,
	[Status] [int] NULL,
	[Salutation] [nvarchar](100) NULL,
	[Remarks] [nvarchar](256) NULL,
	[DeactivationDate] [datetime2](7) NULL,
	[PhoneNo] [nvarchar](100) NULL,
	[IsAdmin] [bit] NOT NULL,
	[IsFavourite] [bit] NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[UserIntial] [nvarchar](4) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsPartnerUser] [bit] NULL,
	[IsPartnerExists] [bit] NULL,
	[ModuleId] [bigint] NULL,
	[Nationality] [nvarchar](30) NULL,
	[Gender] [nvarchar](10) NULL,
	[PhotoId] [uniqueidentifier] NULL,
	[Communication] [nvarchar](1000) NULL,
	[ServiceEntities] [nvarchar](max) NULL,
	[Email] [nvarchar](254) NOT NULL,
	[Version] [timestamp] NOT NULL,
 CONSTRAINT [PK_CompanyUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyUser] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyUser] ADD  DEFAULT ('0B23ADD5-5DA4-4B5C-941C-5F0DF5FD88CC') FOR [UserId]
GO
ALTER TABLE [Common].[CompanyUser] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[CompanyUser]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUser_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyUser] CHECK CONSTRAINT [FK_CompanyUser_Company]
GO
ALTER TABLE [Common].[CompanyUser]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUser_MediaRepository] FOREIGN KEY([PhotoId])
REFERENCES [Common].[MediaRepository] ([Id])
GO
ALTER TABLE [Common].[CompanyUser] CHECK CONSTRAINT [FK_CompanyUser_MediaRepository]
GO
ALTER TABLE [Common].[CompanyUser]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUser_UserAccount] FOREIGN KEY([UserId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Common].[CompanyUser] CHECK CONSTRAINT [FK_CompanyUser_UserAccount]
GO

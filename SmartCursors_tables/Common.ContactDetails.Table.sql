USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ContactDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ContactDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NULL,
	[EntityType] [nvarchar](100) NULL,
	[Designation] [nvarchar](100) NULL,
	[Communication] [nvarchar](1000) NULL,
	[Matters] [nvarchar](1000) NULL,
	[IsPrimaryContact] [bit] NULL,
	[IsReminderReceipient] [bit] NULL,
	[RecOrder] [int] NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[IsPinned] [bit] NULL,
	[CursorShortCode] [nvarchar](20) NULL,
	[Status] [int] NULL,
	[IsCopy] [bit] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](max) NULL,
	[DocId] [uniqueidentifier] NULL,
	[DocType] [nvarchar](30) NULL,
 CONSTRAINT [PK_ContactDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ContactDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ContactDetails]  WITH CHECK ADD  CONSTRAINT [FK_ContactDetails_Account] FOREIGN KEY([ContactId])
REFERENCES [Common].[Contact] ([Id])
GO
ALTER TABLE [Common].[ContactDetails] CHECK CONSTRAINT [FK_ContactDetails_Account]
GO

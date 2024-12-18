USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[AccountContact]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[AccountContact](
	[Id] [uniqueidentifier] NOT NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Communication] [nvarchar](1000) NULL,
	[Website] [nvarchar](1000) NULL,
	[Matters] [nvarchar](1000) NULL,
	[IsPrimaryContact] [bit] NULL,
	[IsReminderReceipient] [bit] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[IsPinned] [bit] NULL,
	[entityid] [int] NULL,
	[Relatedentityid] [int] NULL,
	[Emails] [nvarchar](500) NULL,
 CONSTRAINT [PK_AccountContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[AccountContact] ADD  DEFAULT ((1)) FOR [Status]
GO

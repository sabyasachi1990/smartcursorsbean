USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[AccountNote_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[AccountNote_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Note] [nvarchar](2000) NOT NULL,
	[Rating] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AccountNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[AccountNote_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[AccountNote_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AccountNote_UserAccount] FOREIGN KEY([UserId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [ClientCursor].[AccountNote_ToBeDeleted] CHECK CONSTRAINT [FK_AccountNote_UserAccount]
GO
ALTER TABLE [ClientCursor].[AccountNote_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AccountNotee_Account] FOREIGN KEY([AccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [ClientCursor].[AccountNote_ToBeDeleted] CHECK CONSTRAINT [FK_AccountNotee_Account]
GO

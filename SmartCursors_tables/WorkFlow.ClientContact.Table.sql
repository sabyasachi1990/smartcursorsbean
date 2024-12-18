USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ClientContact]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ClientContact](
	[Id] [uniqueidentifier] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Communication] [nvarchar](1000) NULL,
	[IsPrimaryContact] [bit] NULL,
	[IsReminderReceipient] [bit] NULL,
	[Website] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_ClientContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ClientContact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[ClientContact] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [WorkFlow].[ClientContact]  WITH CHECK ADD  CONSTRAINT [FK_ClientContact_Client] FOREIGN KEY([ClientId])
REFERENCES [WorkFlow].[Client] ([Id])
GO
ALTER TABLE [WorkFlow].[ClientContact] CHECK CONSTRAINT [FK_ClientContact_Client]
GO
ALTER TABLE [WorkFlow].[ClientContact]  WITH CHECK ADD  CONSTRAINT [FK_ClientContact_Contact] FOREIGN KEY([ContactId])
REFERENCES [Common].[Contact] ([Id])
GO
ALTER TABLE [WorkFlow].[ClientContact] CHECK CONSTRAINT [FK_ClientContact_Contact]
GO

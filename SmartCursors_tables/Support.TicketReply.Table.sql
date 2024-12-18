USE [SmartCursorSTG]
GO
/****** Object:  Table [Support].[TicketReply]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Support].[TicketReply](
	[Id] [uniqueidentifier] NOT NULL,
	[TicketId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[IsSupportMember] [bit] NOT NULL,
	[Rating] [decimal](18, 0) NULL,
	[MessageBody] [nvarchar](max) NULL,
	[IsAttachments] [bit] NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[UserType] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
 CONSTRAINT [PK_TicketDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Support].[TicketReply] ADD  DEFAULT ((0)) FOR [IsAttachments]
GO
ALTER TABLE [Support].[TicketReply]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Support].[TicketReply]  WITH CHECK ADD  CONSTRAINT [FK_TicketReply_Ticket] FOREIGN KEY([TicketId])
REFERENCES [Support].[Ticket] ([Id])
GO
ALTER TABLE [Support].[TicketReply] CHECK CONSTRAINT [FK_TicketReply_Ticket]
GO
ALTER TABLE [Support].[TicketReply]  WITH CHECK ADD  CONSTRAINT [FK_TicketReply_UserAccount] FOREIGN KEY([UserId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Support].[TicketReply] CHECK CONSTRAINT [FK_TicketReply_UserAccount]
GO

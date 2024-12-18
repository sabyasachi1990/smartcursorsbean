USE [SmartCursorSTG]
GO
/****** Object:  Table [Support].[Ticket]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Support].[Ticket](
	[Id] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[TicketCategoryId] [uniqueidentifier] NULL,
	[Type] [nvarchar](10) NOT NULL,
	[CCEmails] [nvarchar](1000) NULL,
	[Subject] [nvarchar](256) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[IsAttachments] [bit] NULL,
	[IsUnRead] [bit] NULL,
	[TicketStatus] [int] NOT NULL,
	[TicketsNumber] [bigint] NOT NULL,
	[TicketStatusString] [nvarchar](50) NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsSupportMenber] [bit] NULL,
	[Status] [int] NULL,
	[CursorName] [nvarchar](200) NULL,
	[CompanyName] [nvarchar](200) NULL,
	[UserType] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Priority] [nvarchar](64) NULL,
 CONSTRAINT [PK_Ticket] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Support].[Ticket] ADD  DEFAULT ((0)) FOR [IsAttachments]
GO
ALTER TABLE [Support].[Ticket] ADD  DEFAULT ((1)) FOR [IsUnRead]
GO
ALTER TABLE [Support].[Ticket]  WITH CHECK ADD FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Support].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_TicketCategory] FOREIGN KEY([TicketCategoryId])
REFERENCES [Support].[TicketCategory] ([Id])
GO
ALTER TABLE [Support].[Ticket] CHECK CONSTRAINT [FK_Ticket_TicketCategory]
GO
ALTER TABLE [Support].[Ticket]  WITH CHECK ADD  CONSTRAINT [FK_Ticket_UserAccount] FOREIGN KEY([UserId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Support].[Ticket] CHECK CONSTRAINT [FK_Ticket_UserAccount]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Support].[TicketHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Support].[TicketHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[TicketId] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime2](4) NULL,
	[TicketStatus] [nvarchar](100) NULL,
	[Username] [nvarchar](254) NULL,
 CONSTRAINT [PK_TicketHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Support].[TicketHistory]  WITH CHECK ADD  CONSTRAINT [FK_TicketHistory_Ticket] FOREIGN KEY([TicketId])
REFERENCES [Support].[Ticket] ([Id])
GO
ALTER TABLE [Support].[TicketHistory] CHECK CONSTRAINT [FK_TicketHistory_Ticket]
GO

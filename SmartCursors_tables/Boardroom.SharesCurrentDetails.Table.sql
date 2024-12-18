USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[SharesCurrentDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[SharesCurrentDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[NoofShares] [bigint] NOT NULL,
	[AmntIssuedCapital] [decimal](19, 3) NULL,
	[AmntPaidupCapital] [decimal](19, 3) NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_sharescurrent_details] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[SharesCurrentDetails]  WITH CHECK ADD  CONSTRAINT [FK_transcation_sharescurrentdetails] FOREIGN KEY([TransactionId])
REFERENCES [Boardroom].[Transaction] ([Id])
GO
ALTER TABLE [Boardroom].[SharesCurrentDetails] CHECK CONSTRAINT [FK_transcation_sharescurrentdetails]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[TransactionLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[TransactionLog](
	[Id] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NULL,
	[AllotmentId] [uniqueidentifier] NOT NULL,
	[NoOfShares] [int] NOT NULL,
	[AmntOfPaidup] [decimal](16, 2) NOT NULL,
	[AmntOfIssued] [decimal](16, 2) NOT NULL,
	[TransactionType] [nvarchar](200) NOT NULL,
	[TransactionDate] [datetime2](7) NULL,
	[ShareCertficate] [int] NULL,
	[Nature] [nvarchar](1000) NULL,
	[Description] [nvarchar](200) NOT NULL,
	[State] [nvarchar](25) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NOT NULL,
	[TransactionDetailId] [uniqueidentifier] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[RelationId] [uniqueidentifier] NULL,
	[PricePershare] [decimal](18, 2) NULL,
	[TotalBalance] [bigint] NULL,
 CONSTRAINT [PK_TransactionLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[TransactionLog]  WITH CHECK ADD  CONSTRAINT [PK_TransactionLog_Allotment] FOREIGN KEY([AllotmentId])
REFERENCES [Boardroom].[Allotment] ([Id])
GO
ALTER TABLE [Boardroom].[TransactionLog] CHECK CONSTRAINT [PK_TransactionLog_Allotment]
GO
ALTER TABLE [Boardroom].[TransactionLog]  WITH CHECK ADD  CONSTRAINT [PK_TransactionLog_Contacts] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[Contacts] ([Id])
GO
ALTER TABLE [Boardroom].[TransactionLog] CHECK CONSTRAINT [PK_TransactionLog_Contacts]
GO
ALTER TABLE [Boardroom].[TransactionLog]  WITH CHECK ADD  CONSTRAINT [PK_TransactionLog_Transaction] FOREIGN KEY([TransactionId])
REFERENCES [Boardroom].[Transaction] ([Id])
GO
ALTER TABLE [Boardroom].[TransactionLog] CHECK CONSTRAINT [PK_TransactionLog_Transaction]
GO

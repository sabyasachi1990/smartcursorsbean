USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Transaction]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Transaction](
	[Id] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NULL,
	[TransactionType] [nvarchar](40) NULL,
	[TransactionDate] [datetime2](7) NULL,
	[IsNoofShares] [bit] NULL,
	[IsAmtofPaidupCapital] [bit] NULL,
	[NoOfShares] [int] NOT NULL,
	[AmtofPaidupCapital] [decimal](16, 2) NULL,
	[Amount] [decimal](16, 2) NULL,
	[NatureofTransaction] [nvarchar](4000) NULL,
	[Version] [smallint] NULL,
	[Description] [nvarchar](500) NULL,
	[IsRecent] [bit] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[Status] [int] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Recorder] [int] NULL,
	[AllotmentId] [uniqueidentifier] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModeOfTransaction] [nvarchar](500) NULL,
	[NoOfSharesAltered] [int] NULL,
	[BalanceShares] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[IsFirst] [bit] NULL,
	[ReasonforReissue] [nvarchar](100) NULL,
	[IsShow] [bit] NULL,
	[ShareCertificate] [int] NULL,
	[AmtOfIssuedShareCapital] [decimal](16, 2) NULL,
	[IsReissued] [bit] NULL,
	[AmntDiffrnce] [decimal](16, 4) NULL,
	[AmntIssuedDifrnce] [decimal](16, 4) NULL,
	[IsBalanceZero] [bit] NULL,
	[TranscationMode] [nvarchar](4000) NULL,
	[IsSplit] [bit] NULL,
	[CancelledDocumentId] [uniqueidentifier] NULL,
	[PricePershare] [decimal](16, 4) NULL,
	[RelationId] [uniqueidentifier] NULL,
	[State] [nvarchar](20) NULL,
	[TypeDescription] [nvarchar](500) NULL,
	[ShareGroup] [nvarchar](100) NULL,
	[SharesheldinTrust] [bit] NULL,
	[NameoftheTrust] [nvarchar](100) NULL,
	[ChangeTransId] [uniqueidentifier] NULL,
	[ChangesId] [uniqueidentifier] NULL,
	[CurrencyConsideration] [nvarchar](254) NULL,
	[Consideration] [nvarchar](500) NULL,
	[AlloteMasterTransId] [uniqueidentifier] NULL,
	[TranferedFromContactId] [uniqueidentifier] NULL,
	[ChildTransactionType] [nvarchar](500) NULL,
 CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Boardroom].[Transaction].[AmtofPaidupCapital] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Boardroom].[Transaction].[Amount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Boardroom].[Transaction].[AmtOfIssuedShareCapital] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Boardroom].[Transaction]  WITH CHECK ADD FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Allotment] FOREIGN KEY([AllotmentId])
REFERENCES [Boardroom].[Allotment] ([Id])
GO
ALTER TABLE [Boardroom].[Transaction] CHECK CONSTRAINT [FK_Transaction_Allotment]
GO
ALTER TABLE [Boardroom].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Contacts] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[Contacts] ([Id])
GO
ALTER TABLE [Boardroom].[Transaction] CHECK CONSTRAINT [FK_Transaction_Contacts]
GO
ALTER TABLE [Boardroom].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Transaction] CHECK CONSTRAINT [FK_Transaction_EntityDetail]
GO

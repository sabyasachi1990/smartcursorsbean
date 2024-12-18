USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AllotmentDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AllotmentDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[AllotmentId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NULL,
	[ShareCertificate] [int] NULL,
	[NoOfShares] [int] NOT NULL,
	[Amount] [decimal](18, 2) NULL,
	[PricePerShare] [decimal](16, 4) NULL,
	[ShareGroup] [nvarchar](254) NULL,
	[Recorder] [int] NULL,
	[NameoftheTrust] [nvarchar](100) NULL,
	[IsSharesheldinTrust] [bit] NULL,
	[Status] [int] NULL,
	[TransactionDate] [datetime2](7) NULL,
	[AmtOfIssuedShareCapital] [decimal](16, 2) NULL,
	[AmtOfPaidUpCapital] [decimal](18, 0) NULL,
	[ModeOfTranscation] [nvarchar](2000) NULL,
 CONSTRAINT [PK_AllotmentDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AllotmentDetails] ADD  DEFAULT ((1)) FOR [ShareCertificate]
GO
ALTER TABLE [Boardroom].[AllotmentDetails]  WITH CHECK ADD  CONSTRAINT [FK_AllotmentDetails_Allotment] FOREIGN KEY([AllotmentId])
REFERENCES [Boardroom].[Allotment] ([Id])
GO
ALTER TABLE [Boardroom].[AllotmentDetails] CHECK CONSTRAINT [FK_AllotmentDetails_Allotment]
GO
ALTER TABLE [Boardroom].[AllotmentDetails]  WITH CHECK ADD  CONSTRAINT [FK_AllotmentDetails_Contacts] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[Contacts] ([Id])
GO
ALTER TABLE [Boardroom].[AllotmentDetails] CHECK CONSTRAINT [FK_AllotmentDetails_Contacts]
GO

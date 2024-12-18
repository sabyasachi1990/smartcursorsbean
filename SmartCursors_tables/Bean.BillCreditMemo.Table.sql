USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BillCreditMemo]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BillCreditMemo](
	[Id] [uniqueidentifier] NOT NULL,
	[BillId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocumentType] [nvarchar](25) NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentNumber] [nvarchar](25) NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[NoSupportingDocument] [bit] NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_BillCreditMemo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[BillCreditMemo].[Currency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[BillCreditMemo]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemo_Bill] FOREIGN KEY([BillId])
REFERENCES [Bean].[Bill] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemo] CHECK CONSTRAINT [FK_BillCreditMemo_Bill]
GO
ALTER TABLE [Bean].[BillCreditMemo]  WITH CHECK ADD  CONSTRAINT [FK_BillCreditMemo_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[BillCreditMemo] CHECK CONSTRAINT [FK_BillCreditMemo_Company]
GO

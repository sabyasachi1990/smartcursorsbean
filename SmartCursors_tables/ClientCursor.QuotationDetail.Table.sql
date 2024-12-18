USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[QuotationDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[QuotationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[Revision] [int] NULL,
	[IsModified] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[QuoteAttachment] [nvarchar](1000) NULL,
	[OpportunityId] [uniqueidentifier] NULL,
	[TemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_QuotationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[QuotationDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[QuotationDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuotationDetail_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationDetail] CHECK CONSTRAINT [FK_QuotationDetail_Opportunity]
GO
ALTER TABLE [ClientCursor].[QuotationDetail]  WITH CHECK ADD  CONSTRAINT [FK_QuotationDetail_Quotation] FOREIGN KEY([MasterId])
REFERENCES [ClientCursor].[Quotation] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationDetail] CHECK CONSTRAINT [FK_QuotationDetail_Quotation]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[QuotationHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[QuotationHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[QuotationId] [uniqueidentifier] NOT NULL,
	[OpportunityId] [uniqueidentifier] NULL,
	[Opportunity] [nvarchar](1500) NULL,
	[MongoId] [nvarchar](1500) NULL,
	[User] [nvarchar](250) NULL,
	[Type] [nvarchar](1500) NULL,
	[Attachments] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileName] [nvarchar](500) NULL,
	[AzurePath] [nvarchar](max) NULL,
 CONSTRAINT [PK_QuotationHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[QuotationHistory] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[QuotationHistory]  WITH CHECK ADD  CONSTRAINT [FK_QuotationHistory_Quotation] FOREIGN KEY([QuotationId])
REFERENCES [ClientCursor].[Quotation] ([Id])
GO
ALTER TABLE [ClientCursor].[QuotationHistory] CHECK CONSTRAINT [FK_QuotationHistory_Quotation]
GO

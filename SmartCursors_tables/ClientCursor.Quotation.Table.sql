USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[Quotation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[Quotation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[TotalFee] [money] NULL,
	[Revision] [int] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[SummaryAttachment] [nvarchar](1000) NULL,
	[AccountId] [uniqueidentifier] NULL,
	[QuoteNumber] [nvarchar](50) NULL,
	[IsEmailSent] [bit] NULL,
	[StandardTemplateContent] [nvarchar](max) NULL,
	[RevisedCount] [int] NULL,
	[IsTemparary] [bit] NULL,
	[IsCreated] [bit] NULL,
 CONSTRAINT [PK_Quotation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[Quotation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[Quotation]  WITH CHECK ADD  CONSTRAINT [FK_Quotation_Account] FOREIGN KEY([AccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [ClientCursor].[Quotation] CHECK CONSTRAINT [FK_Quotation_Account]
GO
ALTER TABLE [ClientCursor].[Quotation]  WITH CHECK ADD  CONSTRAINT [FK_Quotation_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[Quotation] CHECK CONSTRAINT [FK_Quotation_Company]
GO

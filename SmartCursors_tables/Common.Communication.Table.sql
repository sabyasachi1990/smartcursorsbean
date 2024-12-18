USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Communication]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Communication](
	[Id] [uniqueidentifier] NOT NULL,
	[CommunicationType] [nvarchar](50) NULL,
	[Description] [nvarchar](1000) NULL,
	[Date] [datetime2](7) NULL,
	[SentBy] [nvarchar](256) NULL,
	[FromMail] [nvarchar](256) NULL,
	[ToMail] [nvarchar](max) NULL,
	[Subject] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[LeadId] [uniqueidentifier] NULL,
	[Remarks] [nvarchar](max) NULL,
	[TemplateId] [uniqueidentifier] NULL,
	[ReportPath] [nvarchar](max) NULL,
	[Category] [nvarchar](100) NULL,
	[TemplateName] [nvarchar](100) NULL,
	[TemplateCode] [nvarchar](max) NULL,
	[InvoiceId] [uniqueidentifier] NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileName] [nvarchar](max) NULL,
	[AzurePath] [nvarchar](max) NULL,
	[InvoiceNumber] [nvarchar](1000) NULL,
	[IsDocuSign] [bit] NULL,
	[TemplateContent] [nvarchar](max) NULL,
	[CCMail] [nvarchar](1000) NULL,
	[BCCMail] [nvarchar](1000) NULL,
	[CursorName] [nvarchar](500) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[Type] [nvarchar](500) NULL,
	[MailgunMessageId] [nvarchar](500) NULL,
	[MailgunMessageStatus] [nvarchar](500) NULL,
	[MailgunErrorMessage] [nvarchar](max) NULL,
	[MailgunDateTime] [datetime] NULL,
	[SendgridMessageId] [nvarchar](500) NULL,
	[SendgridMessageStatus] [nvarchar](500) NULL,
	[SendgridErrorMessage] [nvarchar](max) NULL,
	[SendgridDateTime] [datetime] NULL,
	[CompanyId] [bigint] NULL,
	[O365MessageId] [nvarchar](500) NULL,
	[O365MessageStatus] [nvarchar](500) NULL,
	[O365ErrorMessage] [nvarchar](500) NULL,
	[O365DateTime] [datetime] NULL,
	[RelationId] [uniqueidentifier] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[MailRetried] [bit] NULL,
	[DocuSign] [nvarchar](max) NULL,
	[EnvelopeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Communication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Common].[Communication].[InvoiceNumber] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Common].[Communication] ADD  DEFAULT ((1)) FOR [Status]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[Invoice]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[Invoice](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[PartnerId] [bigint] NULL,
	[InvoiceNumber] [nvarchar](50) NOT NULL,
	[InvoiceDate] [datetime2](7) NOT NULL,
	[BillingAddress] [nvarchar](500) NULL,
	[FilePath] [nvarchar](500) NOT NULL,
	[Status] [nvarchar](50) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[UsagePeriod] [nvarchar](200) NULL,
	[Remarks] [nvarchar](512) NULL,
	[UnpaidAmount] [money] NULL,
	[TotalAmount] [money] NULL,
	[Description] [nvarchar](max) NULL,
	[PayTerm] [nvarchar](200) NULL,
	[InvoiceType] [nvarchar](50) NULL,
	[PartnerInvoiceNumber] [nvarchar](50) NULL,
	[PartnerAmount] [money] NULL,
	[IsPartnerToClient] [bit] NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

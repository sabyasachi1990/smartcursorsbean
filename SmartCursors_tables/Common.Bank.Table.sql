USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Bank]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Bank](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[SubcidaryCompanyId] [bigint] NULL,
	[ShortCode] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[BranchCode] [nvarchar](50) NULL,
	[BranchName] [nvarchar](100) NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[AccountName] [nvarchar](100) NULL,
	[SwiftCode] [nvarchar](50) NULL,
	[AddressBookId] [uniqueidentifier] NULL,
	[COAId] [bigint] NULL,
	[Currency] [nvarchar](5) NULL,
	[BankAddress] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ShortName] [nvarchar](5) NULL,
	[Purpose] [nvarchar](20) NULL,
	[BankCompanyCode] [nvarchar](50) NULL,
	[COAName] [nvarchar](100) NULL,
 CONSTRAINT [PK_Bank] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Bank] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[Bank] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Bank]  WITH CHECK ADD  CONSTRAINT [FK_Bank_AddressBook] FOREIGN KEY([AddressBookId])
REFERENCES [Common].[AddressBook] ([Id])
GO
ALTER TABLE [Common].[Bank] CHECK CONSTRAINT [FK_Bank_AddressBook]
GO
ALTER TABLE [Common].[Bank]  WITH CHECK ADD  CONSTRAINT [FK_Bank_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Common].[Bank] CHECK CONSTRAINT [FK_Bank_ChartOfAccount]
GO
ALTER TABLE [Common].[Bank]  WITH CHECK ADD  CONSTRAINT [FK_Bank_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Bank] CHECK CONSTRAINT [FK_Bank_Company]
GO

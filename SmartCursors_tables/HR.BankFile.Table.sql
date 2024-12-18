USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[BankFile]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[BankFile](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[SubCompanyId] [bigint] NOT NULL,
	[BankCompanyId] [nvarchar](50) NOT NULL,
	[BankCode] [nvarchar](50) NOT NULL,
	[BankName] [nvarchar](200) NOT NULL,
	[ValueDate] [datetime2](7) NOT NULL,
	[OriginatorAccNum] [nvarchar](200) NOT NULL,
	[OriginatorAccName] [nvarchar](400) NOT NULL,
	[BatchId] [nvarchar](10) NOT NULL,
	[BatchReference] [nvarchar](200) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[FileName] [nvarchar](500) NULL,
	[FilePath] [nvarchar](500) NULL,
	[Type] [nvarchar](200) NULL,
 CONSTRAINT [PK_BankFile] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[BankFile]  WITH CHECK ADD  CONSTRAINT [PK_BankFile_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[BankFile] CHECK CONSTRAINT [PK_BankFile_Company]
GO

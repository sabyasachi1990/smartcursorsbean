USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroTokenStore]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroTokenStore](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[ModuleMasterId] [bigint] NULL,
	[Session_Handle] [nvarchar](2000) NULL,
	[Access_Token_Secret] [nvarchar](2000) NULL,
	[Access_Token_Key] [nvarchar](2000) NULL,
	[UserId] [nvarchar](2000) NULL,
	[ConsumerKey] [nvarchar](2000) NULL,
	[ConsumerSecret] [nvarchar](2000) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Organisation_ShortCode] [nvarchar](50) NULL,
	[Organisation_Name] [nvarchar](500) NULL,
	[Organisation_Id] [uniqueidentifier] NULL,
	[token_key] [nvarchar](1000) NULL,
	[Organisation_Currency] [nvarchar](20) NULL,
	[ExpiresAt] [datetime2](7) NULL,
	[SessionExpiresAt] [datetime2](7) NULL,
	[HasExpired] [bit] NULL,
	[HasSessionExpired] [bit] NULL,
 CONSTRAINT [PK_XeroTokenStore] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

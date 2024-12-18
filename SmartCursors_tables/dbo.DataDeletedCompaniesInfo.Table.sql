USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[DataDeletedCompaniesInfo]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataDeletedCompaniesInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NULL,
	[CompanyName] [varchar](max) NULL,
	[RegistrationNumber] [varchar](500) NULL,
	[DeletedDate] [datetime2](7) NULL,
	[ErrorDate] [datetime2](7) NULL,
	[ErrorMessage] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

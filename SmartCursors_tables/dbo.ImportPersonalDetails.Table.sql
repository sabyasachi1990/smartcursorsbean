USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportPersonalDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportPersonalDetails](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](2000) NOT NULL,
	[Name] [nvarchar](2000) NULL,
	[IdType] [nvarchar](2000) NULL,
	[IdNumber] [nvarchar](2000) NULL,
	[Nationality] [nvarchar](2000) NULL,
	[Race] [nvarchar](2000) NULL,
	[DateofBirth] [nvarchar](2000) NULL,
	[Age] [int] NULL,
	[Gender] [nvarchar](2000) NULL,
	[MaritalStatus] [nvarchar](2000) NULL,
	[PassPortNumber] [nvarchar](2000) NULL,
	[PassportExpiry] [nvarchar](2000) NULL,
	[UserName] [nvarchar](2000) NULL,
	[LocalAddress] [nvarchar](4000) NULL,
	[Foreignaddress] [nvarchar](4000) NULL,
	[Email] [nvarchar](2000) NULL,
	[Mobile] [nvarchar](2000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
	[DateofSPRGranted] [nvarchar](400) NULL,
 CONSTRAINT [Pk_Details] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportFamily]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportFamily](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](2000) NOT NULL,
	[Name] [nvarchar](2000) NULL,
	[Relation] [nvarchar](2000) NULL,
	[Nationality] [nvarchar](2000) NULL,
	[IDNo] [nvarchar](2000) NULL,
	[DateofBirth] [nvarchar](2000) NULL,
	[Age] [int] NULL,
	[ContactNo] [nvarchar](2000) NULL,
	[NameofEmployer/School] [nvarchar](2000) NULL,
	[EmergencyContact] [bit] NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_Family] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

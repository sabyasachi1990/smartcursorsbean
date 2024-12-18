USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportQualification]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportQualification](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](2000) NOT NULL,
	[Type] [nvarchar](2000) NULL,
	[Qualification] [nvarchar](400) NULL,
	[Institution] [nvarchar](4000) NULL,
	[StartDate] [nvarchar](2000) NULL,
	[EndDate] [nvarchar](2000) NULL,
	[Attachments] [nvarchar](2000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_Qualification] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

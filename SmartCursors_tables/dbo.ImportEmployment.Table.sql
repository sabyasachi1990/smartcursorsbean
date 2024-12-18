USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[ImportEmployment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportEmployment](
	[ID] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [nvarchar](2000) NOT NULL,
	[TypeofEmployment] [nvarchar](2000) NULL,
	[EmploymentStartDate] [nvarchar](2000) NULL,
	[EmploymentEndDate] [nvarchar](2000) NULL,
	[Period] [nvarchar](2000) NULL,
	[Days/Months] [int] NULL,
	[ConfirmationDate] [nvarchar](2000) NULL,
	[ConfirmationRemarks] [nvarchar](max) NULL,
	[RejoinDate] [nvarchar](2000) NULL,
	[ErrorRemarks] [nvarchar](max) NULL,
	[ImportStatus] [bit] NULL,
 CONSTRAINT [Pk_Employment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

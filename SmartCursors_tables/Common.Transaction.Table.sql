USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Transaction]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Transaction](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[ScreenName] [nvarchar](100) NOT NULL,
	[UploadBy] [nvarchar](254) NULL,
	[UploadDate] [datetime2](7) NULL,
	[Status] [nvarchar](254) NULL,
	[TotalRecords] [int] NULL,
	[FailedRecords] [int] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[FilePath] [nvarchar](max) NULL,
 CONSTRAINT [PK_Transacation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Transaction]  WITH CHECK ADD  CONSTRAINT [FK_Transaction_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Transaction] CHECK CONSTRAINT [FK_Transaction_Company]
GO

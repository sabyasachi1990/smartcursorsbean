USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DeleteLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DeleteLog](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[DocType] [nvarchar](50) NULL,
	[TransactionId] [uniqueidentifier] NULL,
	[DocNo] [nvarchar](50) NULL,
	[DeletedBy] [nvarchar](250) NULL,
	[DeletedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[DeleteLog]  WITH CHECK ADD  CONSTRAINT [FK_DeleteLog_Company_Id] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[DeleteLog] CHECK CONSTRAINT [FK_DeleteLog_Company_Id]
GO

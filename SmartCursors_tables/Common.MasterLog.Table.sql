USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[MasterLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MasterLog](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Log_Message] [nvarchar](1000) NOT NULL,
	[Step] [nvarchar](10) NOT NULL,
	[ExceptionMessage] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Status] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_MasterLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[MasterLog]  WITH CHECK ADD  CONSTRAINT [FK_MasterLog_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[MasterLog] CHECK CONSTRAINT [FK_MasterLog_Company]
GO

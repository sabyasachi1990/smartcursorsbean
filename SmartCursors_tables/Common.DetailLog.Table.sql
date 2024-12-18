USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DetailLog]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DetailLog](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[Log_Message] [nvarchar](1000) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Step] [nvarchar](10) NOT NULL,
	[ExceptionMessage] [nvarchar](max) NULL,
	[Status] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_DetailLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[DetailLog]  WITH CHECK ADD  CONSTRAINT [FK_DetailLog_MasterLog] FOREIGN KEY([MasterId])
REFERENCES [Common].[MasterLog] ([Id])
GO
ALTER TABLE [Common].[DetailLog] CHECK CONSTRAINT [FK_DetailLog_MasterLog]
GO

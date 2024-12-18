USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[TempAttendence]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempAttendence](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FileName] [nvarchar](max) NOT NULL,
	[Status] [nvarchar](10) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_TempAttendance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempAttendence]  WITH CHECK ADD  CONSTRAINT [FK_TempAttendance_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [dbo].[TempAttendence] CHECK CONSTRAINT [FK_TempAttendance_Company]
GO

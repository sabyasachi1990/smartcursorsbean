USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AttendanceAttachments]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AttendanceAttachments](
	[Id] [uniqueidentifier] NOT NULL,
	[DateOfUpload] [datetime2](7) NULL,
	[UploadedBy] [nvarchar](500) NULL,
	[AttachmentPath] [nvarchar](max) NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[CompanyId] [bigint] NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[UploadStatus] [nvarchar](40) NULL,
 CONSTRAINT [PK_AttendanceAttachments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[AttendanceAttachments]  WITH CHECK ADD  CONSTRAINT [FK_AttendanceAttachments_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[AttendanceAttachments] CHECK CONSTRAINT [FK_AttendanceAttachments_Company]
GO

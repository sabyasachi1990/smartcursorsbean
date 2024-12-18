USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[ScheduleAttachment_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[ScheduleAttachment_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[ScheduleId] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](100) NULL,
	[FilePath] [nvarchar](100) NULL,
	[FileSize] [decimal](18, 0) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ScheduleAttachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[ScheduleAttachment_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[ScheduleAttachment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ScheduleAttachment_Note] FOREIGN KEY([ScheduleId])
REFERENCES [Tax].[Schedule_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[ScheduleAttachment_ToBeDeleted] CHECK CONSTRAINT [FK_ScheduleAttachment_Note]
GO

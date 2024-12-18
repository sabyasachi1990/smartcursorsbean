USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[TempAttendenceDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempAttendenceDetails](
	[Id] [bigint] NOT NULL,
	[TempAttendenceId] [bigint] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Time] [time](7) NULL,
	[EmployeeName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_TempAttendenceDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempAttendenceDetails]  WITH CHECK ADD  CONSTRAINT [FK_TempAttendenceDetails_TempAttendence] FOREIGN KEY([TempAttendenceId])
REFERENCES [dbo].[TempAttendence] ([Id])
GO
ALTER TABLE [dbo].[TempAttendenceDetails] CHECK CONSTRAINT [FK_TempAttendenceDetails_TempAttendence]
GO

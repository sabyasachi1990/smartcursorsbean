USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[Date] [datetime2](7) NULL,
	[Duration] [time](7) NOT NULL,
	[Remarks] [nvarchar](4000) NULL,
	[PBIName] [nvarchar](max) NULL,
	[TimeLogScheduleId] [uniqueidentifier] NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[ChargeoutRate] [decimal](28, 9) NULL,
	[Level] [int] NULL,
	[IsAdmin] [bit] NULL,
 CONSTRAINT [PK_TimeLogDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogDetail]  WITH CHECK ADD FOREIGN KEY([TimeLogScheduleId])
REFERENCES [Common].[TimeLogSchedule] ([Id])
GO
ALTER TABLE [Common].[TimeLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogDetail_TimeLog] FOREIGN KEY([MasterId])
REFERENCES [Common].[TimeLog] ([Id])
GO
ALTER TABLE [Common].[TimeLogDetail] CHECK CONSTRAINT [FK_TimeLogDetail_TimeLog]
GO

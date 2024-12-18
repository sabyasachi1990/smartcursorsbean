USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogItemDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogItemDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[TimeLogItemId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[IsNew] [bit] NULL,
 CONSTRAINT [PK_TimeLogItemDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogItemDetail_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [Common].[TimeLogItemDetail] CHECK CONSTRAINT [FK_TimeLogItemDetail_Employee]
GO
ALTER TABLE [Common].[TimeLogItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogItemDetail_TimeLogItem] FOREIGN KEY([TimeLogItemId])
REFERENCES [Common].[TimeLogItem] ([Id])
GO
ALTER TABLE [Common].[TimeLogItemDetail] CHECK CONSTRAINT [FK_TimeLogItemDetail_TimeLogItem]
GO

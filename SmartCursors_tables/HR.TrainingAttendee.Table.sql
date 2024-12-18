USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TrainingAttendee]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TrainingAttendee](
	[Id] [uniqueidentifier] NOT NULL,
	[TrainingId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[EmployeeTrainigStatus] [nvarchar](30) NULL,
	[RegisteredDate] [datetime2](7) NULL,
	[WithdrawlDate] [datetime2](7) NULL,
	[EmployeeRemarks] [nvarchar](256) NULL,
	[TrainingCertificateFilePath] [varchar](1000) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
 CONSTRAINT [PK_TrainingDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TrainingAttendee]  WITH CHECK ADD  CONSTRAINT [FK_TrainingDetails_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendee] CHECK CONSTRAINT [FK_TrainingDetails_Department]
GO
ALTER TABLE [HR].[TrainingAttendee]  WITH CHECK ADD  CONSTRAINT [FK_TrainingDetails_Designation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendee] CHECK CONSTRAINT [FK_TrainingDetails_Designation]
GO
ALTER TABLE [HR].[TrainingAttendee]  WITH CHECK ADD  CONSTRAINT [FK_TrainingDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendee] CHECK CONSTRAINT [FK_TrainingDetails_Employee]
GO
ALTER TABLE [HR].[TrainingAttendee]  WITH CHECK ADD  CONSTRAINT [FK_TrainingDetails_Training] FOREIGN KEY([TrainingId])
REFERENCES [HR].[Training] ([Id])
GO
ALTER TABLE [HR].[TrainingAttendee] CHECK CONSTRAINT [FK_TrainingDetails_Training]
GO

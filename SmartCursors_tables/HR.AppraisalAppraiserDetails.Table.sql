USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalAppraiserDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalAppraiserDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[Recorder] [int] NULL,
	[AppraiseeIds] [nvarchar](3000) NULL,
 CONSTRAINT [PK_AppraisalAppraiserDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiserDetails_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails] CHECK CONSTRAINT [FK_AppraisalAppraiserDetails_Appraisal]
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiserDetails_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails] CHECK CONSTRAINT [FK_AppraisalAppraiserDetails_Department]
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiserDetails_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails] CHECK CONSTRAINT [FK_AppraisalAppraiserDetails_DepartmentDesignation]
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiserDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiserDetails] CHECK CONSTRAINT [FK_AppraisalAppraiserDetails_Employee]
GO

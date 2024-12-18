USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalAppraiseeDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalAppraiseeDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[Level] [int] NULL,
	[Recorder] [int] NULL,
	[AppraiserIds] [nvarchar](3000) NULL,
	[RepliedCount] [int] NULL,
	[AppraiserCount] [int] NULL,
	[AppraiseeModifiedBy] [nvarchar](254) NULL,
	[AppraiseeModifiedDate] [datetime2](7) NULL,
	[TemplateContent] [nvarchar](max) NULL,
	[IsSelected] [bit] NULL,
	[NotReplied] [int] NULL,
 CONSTRAINT [PK_AppraisalAppraiseeDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiseeDetails_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails] CHECK CONSTRAINT [FK_AppraisalAppraiseeDetails_Appraisal]
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiseeDetails_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails] CHECK CONSTRAINT [FK_AppraisalAppraiseeDetails_Department]
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiseeDetails_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails] CHECK CONSTRAINT [FK_AppraisalAppraiseeDetails_DepartmentDesignation]
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalAppraiseeDetails_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeDetails] CHECK CONSTRAINT [FK_AppraisalAppraiseeDetails_Employee]
GO

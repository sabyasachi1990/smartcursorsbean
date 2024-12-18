USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[AppraiserId] [uniqueidentifier] NOT NULL,
	[Level] [nvarchar](20) NULL,
	[IsAccepted] [bit] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_AppraisalDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalDetail]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalDetail_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalDetail] CHECK CONSTRAINT [FK_AppraisalDetail_Appraisal]
GO
ALTER TABLE [HR].[AppraisalDetail]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalDetail_Department] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [HR].[AppraisalDetail] CHECK CONSTRAINT [FK_AppraisalDetail_Department]
GO
ALTER TABLE [HR].[AppraisalDetail]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalDetail_DepartmentDesignation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[DepartmentDesignation] ([Id])
GO
ALTER TABLE [HR].[AppraisalDetail] CHECK CONSTRAINT [FK_AppraisalDetail_DepartmentDesignation]
GO
ALTER TABLE [HR].[AppraisalDetail]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalDetail_Employee] FOREIGN KEY([AppraiserId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraisalDetail] CHECK CONSTRAINT [FK_AppraisalDetail_Employee]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalDevelopmentPlan]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalDevelopmentPlan](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[DevelopmentPlanId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Progress] [int] NULL,
	[Comment] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[ObjectiveMet] [bit] NULL,
	[DevelopmentPlanMethod] [nvarchar](100) NULL,
	[AppraiseeId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AppraisalDevelopmentPlan] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalDevelopmentPlan] ADD  DEFAULT ((0)) FOR [Progress]
GO
ALTER TABLE [HR].[AppraisalDevelopmentPlan]  WITH CHECK ADD  CONSTRAINT [FK_AppraisalDevelopmentPlan_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalDevelopmentPlan] CHECK CONSTRAINT [FK_AppraisalDevelopmentPlan_Appraisal]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningAndCompletionSetUpMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningAndCompletionSetUpMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxManualId] [uniqueidentifier] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_planningandcompletionsetupMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningAndCompletionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetupMaster_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[PlanningAndCompletionSetUpMaster] CHECK CONSTRAINT [FK_planningandcompletionsetupMaster_Company]
GO
ALTER TABLE [Tax].[PlanningAndCompletionSetUpMaster]  WITH CHECK ADD  CONSTRAINT [FK_planningandcompletionsetupMaster_TaxManual] FOREIGN KEY([TaxManualId])
REFERENCES [Tax].[TaxManual] ([Id])
GO
ALTER TABLE [Tax].[PlanningAndCompletionSetUpMaster] CHECK CONSTRAINT [FK_planningandcompletionsetupMaster_TaxManual]
GO

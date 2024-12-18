USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PlanningMaterialitySetup_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PlanningMaterialitySetup_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ShortCode] [nvarchar](10) NULL,
	[Decsription] [nvarchar](256) NULL,
	[Rationale] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_PlanningMaterialitySetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PlanningMaterialitySetup_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[PlanningMaterialitySetup_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_PlanningMaterialitySetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[PlanningMaterialitySetup_ToBeDeleted] CHECK CONSTRAINT [FK_PlanningMaterialitySetup_Company]
GO

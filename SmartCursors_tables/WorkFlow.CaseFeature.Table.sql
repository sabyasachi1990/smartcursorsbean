USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseFeature]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseFeature](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[IsProduct] [bit] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
	[State] [nvarchar](50) NULL,
	[Hours] [decimal](7, 2) NULL,
	[PlannedHours] [decimal](7, 2) NULL,
 CONSTRAINT [PK_CaseGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseFeature] ADD  DEFAULT ((0)) FOR [IsProduct]
GO
ALTER TABLE [WorkFlow].[CaseFeature] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseFeature]  WITH CHECK ADD  CONSTRAINT [PK_CaseGroup_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseFeature] CHECK CONSTRAINT [PK_CaseGroup_CaseGroup]
GO

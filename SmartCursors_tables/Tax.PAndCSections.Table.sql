USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[PAndCSections]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[PAndCSections](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NOT NULL,
	[Heading] [nvarchar](256) NULL,
	[Description] [nvarchar](4000) NULL,
	[CommentLable] [nvarchar](256) NULL,
	[CommentDescription] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_PAndCSections] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[PAndCSections] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[PAndCSections]  WITH CHECK ADD  CONSTRAINT [FK_PAndCSections_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Tax].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Tax].[PAndCSections] CHECK CONSTRAINT [FK_PAndCSections_PlanningAndCompletionSetUp]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[PAndCSections]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[PAndCSections](
	[Id] [uniqueidentifier] NOT NULL,
	[PlanningAndCompletionSetUpId] [uniqueidentifier] NOT NULL,
	[Heading] [nvarchar](4000) NULL,
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
ALTER TABLE [Audit].[PAndCSections] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[PAndCSections]  WITH CHECK ADD  CONSTRAINT [FK_PAndCSections_PlanningAndCompletionSetUp] FOREIGN KEY([PlanningAndCompletionSetUpId])
REFERENCES [Audit].[PlanningAndCompletionSetUp] ([Id])
GO
ALTER TABLE [Audit].[PAndCSections] CHECK CONSTRAINT [FK_PAndCSections_PlanningAndCompletionSetUp]
GO

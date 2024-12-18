USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[NoteAdjustment_ToBeDeleted]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[NoteAdjustment_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[NoteId] [uniqueidentifier] NOT NULL,
	[AdjustmentId] [uniqueidentifier] NOT NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_NoteAdjustment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[NoteAdjustment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_NoteAdjustment_Adjustment] FOREIGN KEY([AdjustmentId])
REFERENCES [Tax].[Adjustment] ([ID])
GO
ALTER TABLE [Tax].[NoteAdjustment_ToBeDeleted] CHECK CONSTRAINT [FK_NoteAdjustment_Adjustment]
GO
ALTER TABLE [Tax].[NoteAdjustment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_NoteAdjustmentNote] FOREIGN KEY([NoteId])
REFERENCES [Tax].[Schedule_ToBeDeleted] ([Id])
GO
ALTER TABLE [Tax].[NoteAdjustment_ToBeDeleted] CHECK CONSTRAINT [FK_NoteAdjustmentNote]
GO

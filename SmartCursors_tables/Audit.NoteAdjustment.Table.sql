USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[NoteAdjustment]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[NoteAdjustment](
	[Id] [uniqueidentifier] NOT NULL,
	[NoteId] [uniqueidentifier] NOT NULL,
	[AdjustmentId] [uniqueidentifier] NOT NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[AdjustmentName] [nvarchar](50) NULL,
 CONSTRAINT [PK_NoteAdjustment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[NoteAdjustment]  WITH CHECK ADD  CONSTRAINT [FK_NoteAdjustment_Adjustment] FOREIGN KEY([AdjustmentId])
REFERENCES [Audit].[Adjustment] ([ID])
GO
ALTER TABLE [Audit].[NoteAdjustment] CHECK CONSTRAINT [FK_NoteAdjustment_Adjustment]
GO
ALTER TABLE [Audit].[NoteAdjustment]  WITH CHECK ADD  CONSTRAINT [FK_NoteAdjustmentNote] FOREIGN KEY([NoteId])
REFERENCES [Audit].[Note] ([Id])
GO
ALTER TABLE [Audit].[NoteAdjustment] CHECK CONSTRAINT [FK_NoteAdjustmentNote]
GO

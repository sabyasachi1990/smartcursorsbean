USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AdjustmentComment_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AdjustmentComment_ToBeDeleted](
	[ID] [uniqueidentifier] NOT NULL,
	[CommentID] [uniqueidentifier] NULL,
	[AdjustmentID] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AdjustmentComment_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AdjustmentComment_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AdjustmentComment_Adjustment] FOREIGN KEY([AdjustmentID])
REFERENCES [Audit].[Adjustment] ([ID])
GO
ALTER TABLE [Audit].[AdjustmentComment_ToBeDeleted] CHECK CONSTRAINT [FK_AdjustmentComment_Adjustment]
GO

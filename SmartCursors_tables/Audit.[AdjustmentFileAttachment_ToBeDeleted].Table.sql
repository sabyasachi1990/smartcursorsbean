USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[[AdjustmentFileAttachment_ToBeDeleted]]]    Script Date: 16-12-2024 9.30.54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[[AdjustmentFileAttachment_ToBeDeleted]]](
	[ID] [uniqueidentifier] NOT NULL,
	[AdjustmentID] [uniqueidentifier] NULL,
	[FileName] [nvarchar](275) NULL,
	[FilePath] [nvarchar](500) NULL,
	[FileSize] [int] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_AdjustmentFileAttachments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[[AdjustmentFileAttachment_ToBeDeleted]]] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[[AdjustmentFileAttachment_ToBeDeleted]]]  WITH CHECK ADD  CONSTRAINT [FK_AdjustmentFileAttachment_Adjustment] FOREIGN KEY([AdjustmentID])
REFERENCES [Audit].[Adjustment] ([ID])
GO
ALTER TABLE [Audit].[[AdjustmentFileAttachment_ToBeDeleted]]] CHECK CONSTRAINT [FK_AdjustmentFileAttachment_Adjustment]
GO

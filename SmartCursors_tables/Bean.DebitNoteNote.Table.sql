USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DebitNoteNote]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DebitNoteNote](
	[Id] [uniqueidentifier] NOT NULL,
	[DebitNoteId] [uniqueidentifier] NOT NULL,
	[ExpectedPaymentDate] [datetime2](7) NULL,
	[Notes] [nvarchar](512) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated ] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_DebitNoteNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DebitNoteNote]  WITH CHECK ADD  CONSTRAINT [FK_DebitNoteNote_DebitNote] FOREIGN KEY([DebitNoteId])
REFERENCES [Bean].[DebitNote] ([Id])
GO
ALTER TABLE [Bean].[DebitNoteNote] CHECK CONSTRAINT [FK_DebitNoteNote_DebitNote]
GO

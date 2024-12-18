USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Split]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Split](
	[Id] [uniqueidentifier] NOT NULL,
	[Particular] [nvarchar](250) NULL,
	[Amount] [decimal](15, 2) NULL,
	[Remarks] [nvarchar](500) NULL,
	[NoteId] [uniqueidentifier] NOT NULL,
	[ReferScreenName] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Split] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[Split].[Amount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[Split]  WITH CHECK ADD  CONSTRAINT [FK_Split_Note] FOREIGN KEY([NoteId])
REFERENCES [Tax].[Note] ([Id])
GO
ALTER TABLE [Tax].[Split] CHECK CONSTRAINT [FK_Split_Note]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[FormDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[FormDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[FormMasterId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[IsChecked] [bit] NULL,
	[VariableName] [nvarchar](100) NULL,
	[IsSelectAll] [bit] NULL,
	[CheckedOrder] [int] NULL,
 CONSTRAINT [PK_FormDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[FormDetail] ADD  DEFAULT ((0)) FOR [IsChecked]
GO
ALTER TABLE [Tax].[FormDetail] ADD  DEFAULT ((0)) FOR [IsSelectAll]
GO
ALTER TABLE [Tax].[FormDetail]  WITH CHECK ADD  CONSTRAINT [FK_FormDetail_FormMaster] FOREIGN KEY([FormMasterId])
REFERENCES [Tax].[FormMaster] ([Id])
GO
ALTER TABLE [Tax].[FormDetail] CHECK CONSTRAINT [FK_FormDetail_FormMaster]
GO

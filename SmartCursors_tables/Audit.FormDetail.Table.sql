USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[FormDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[FormDetail](
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
ALTER TABLE [Audit].[FormDetail] ADD  DEFAULT ((0)) FOR [IsChecked]
GO
ALTER TABLE [Audit].[FormDetail] ADD  DEFAULT ((0)) FOR [IsSelectAll]
GO
ALTER TABLE [Audit].[FormDetail]  WITH CHECK ADD  CONSTRAINT [FK_FormDetail_FormMaster] FOREIGN KEY([FormMasterId])
REFERENCES [Audit].[FormMaster] ([Id])
GO
ALTER TABLE [Audit].[FormDetail] CHECK CONSTRAINT [FK_FormDetail_FormMaster]
GO

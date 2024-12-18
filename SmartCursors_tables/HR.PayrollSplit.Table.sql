USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[PayrollSplit]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[PayrollSplit](
	[Id] [uniqueidentifier] NOT NULL,
	[PayrollDetailId] [uniqueidentifier] NOT NULL,
	[PayComponentId] [uniqueidentifier] NOT NULL,
	[PayType] [nvarchar](50) NOT NULL,
	[Amount] [money] NULL,
	[Recorder] [int] NULL,
	[IsTemporary] [bit] NULL,
	[IsAgencyFundModified] [bit] NULL,
	[NoOfDays] [float] NULL,
 CONSTRAINT [PK_PayrollSplit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[PayrollSplit]  WITH CHECK ADD  CONSTRAINT [FK_PayrollSplit_PayComponent] FOREIGN KEY([PayComponentId])
REFERENCES [HR].[PayComponent] ([Id])
GO
ALTER TABLE [HR].[PayrollSplit] CHECK CONSTRAINT [FK_PayrollSplit_PayComponent]
GO
ALTER TABLE [HR].[PayrollSplit]  WITH CHECK ADD  CONSTRAINT [FK_PayrollSplit_PayrollDetails] FOREIGN KEY([PayrollDetailId])
REFERENCES [HR].[PayrollDetails] ([Id])
GO
ALTER TABLE [HR].[PayrollSplit] CHECK CONSTRAINT [FK_PayrollSplit_PayrollDetails]
GO

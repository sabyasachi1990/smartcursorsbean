USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CarryForwardDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CarryForwardDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CarryForwardId] [uniqueidentifier] NOT NULL,
	[ShareHolderName] [nvarchar](100) NULL,
	[StDatePercentage] [decimal](15, 2) NULL,
	[EndDatePercentage] [decimal](15, 2) NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_CarryForwardDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[CarryForwardDetail]  WITH CHECK ADD  CONSTRAINT [FK_CarryForwardDetail_CarryForward] FOREIGN KEY([CarryForwardId])
REFERENCES [Tax].[CarryForward] ([Id])
GO
ALTER TABLE [Tax].[CarryForwardDetail] CHECK CONSTRAINT [FK_CarryForwardDetail_CarryForward]
GO

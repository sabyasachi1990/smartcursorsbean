USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[AdjustmentStatusHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[AdjustmentStatusHistory](
	[ID] [uniqueidentifier] NOT NULL,
	[AdjustmentID] [uniqueidentifier] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[FromProposed] [bit] NULL,
	[FromMake] [bit] NULL,
	[FromWaive] [bit] NULL,
	[ToProposed] [bit] NULL,
	[ToMake] [bit] NULL,
	[ToWaive] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[ShortName] [nvarchar](100) NULL,
 CONSTRAINT [PK_AdjustmentStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[AdjustmentStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_AdjustmentStatus_Adjustment] FOREIGN KEY([AdjustmentID])
REFERENCES [Tax].[Adjustment] ([ID])
GO
ALTER TABLE [Tax].[AdjustmentStatusHistory] CHECK CONSTRAINT [FK_AdjustmentStatus_Adjustment]
GO

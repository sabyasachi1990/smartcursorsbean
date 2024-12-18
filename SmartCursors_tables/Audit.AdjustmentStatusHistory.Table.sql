USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AdjustmentStatusHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AdjustmentStatusHistory](
	[ID] [uniqueidentifier] NOT NULL,
	[AdjustmentID] [uniqueidentifier] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[ShortName] [nvarchar](100) NULL,
 CONSTRAINT [PK_AdjustmentStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

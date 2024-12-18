USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Category]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Category](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[Name] [nvarchar](100) NULL,
	[Type] [nvarchar](50) NULL,
	[Recorder] [int] NULL,
	[IsIncomeStatement] [bit] NULL,
	[ClassificationId] [uniqueidentifier] NULL,
	[ColorCode] [nvarchar](100) NULL,
	[AccountClass] [nvarchar](100) NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[Category].[AccountClass] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO

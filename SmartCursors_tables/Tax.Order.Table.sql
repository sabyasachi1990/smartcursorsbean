USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Order]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Order](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[ClassificationType] [nvarchar](50) NULL,
	[AccountClass] [nvarchar](50) NULL,
	[Recorder] [nvarchar](max) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[IsCollapse] [bit] NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[Order].[AccountClass] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AccountBatch]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AccountBatch](
	[Id] [uniqueidentifier] NOT NULL,
	[AccountName] [nvarchar](100) NOT NULL,
	[IsAccount] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreateDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AccountBatch] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AccountBatch] ADD  DEFAULT ((1)) FOR [Status]
GO

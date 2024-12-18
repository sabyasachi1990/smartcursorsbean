USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[StatementAPerticular]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[StatementAPerticular](
	[Id] [uniqueidentifier] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NULL,
	[TableName] [nvarchar](100) NULL,
	[SubTableName] [nvarchar](100) NULL,
	[AmountColumnName] [nvarchar](100) NULL,
	[Condition] [nvarchar](100) NULL,
	[Recorder] [int] NULL,
	[Annotation] [nvarchar](100) NULL,
	[AnnotationDesc] [nvarchar](100) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_StatementAPerticular] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

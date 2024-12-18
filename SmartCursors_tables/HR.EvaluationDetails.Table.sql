USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[EvaluationDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[EvaluationDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](500) NULL,
	[Type] [nvarchar](50) NULL,
	[Value] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EvaluationDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[EvaluationDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[EvaluationDetails]  WITH CHECK ADD  CONSTRAINT [FK_EvaluationDetails_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[EvaluationDetails] CHECK CONSTRAINT [FK_EvaluationDetails_Company]
GO

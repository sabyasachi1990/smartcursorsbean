USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DepartmentDesignation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DepartmentDesignation](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](20) NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[DepartmentRank] [int] NULL,
	[Level] [nvarchar](20) NULL,
	[LevelRank] [int] NULL,
	[IsApplicable] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Rank] [int] NULL,
 CONSTRAINT [PK_DepartmentDesignation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[DepartmentDesignation] ADD  DEFAULT ((0)) FOR [DepartmentRank]
GO
ALTER TABLE [Common].[DepartmentDesignation] ADD  DEFAULT ((0)) FOR [LevelRank]
GO
ALTER TABLE [Common].[DepartmentDesignation] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[DepartmentDesignation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[DepartmentDesignation]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentDesignation_DepartmentId] FOREIGN KEY([DepartmentId])
REFERENCES [Common].[Department] ([Id])
GO
ALTER TABLE [Common].[DepartmentDesignation] CHECK CONSTRAINT [FK_DepartmentDesignation_DepartmentId]
GO

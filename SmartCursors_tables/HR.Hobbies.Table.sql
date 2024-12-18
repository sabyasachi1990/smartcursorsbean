USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Hobbies]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Hobbies](
	[Id] [uniqueidentifier] NOT NULL,
	[JobApplicationId] [uniqueidentifier] NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[Name] [nvarchar](100) NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Hobbies_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Hobbies]  WITH CHECK ADD  CONSTRAINT [FK_Hobbies_EmployeeId] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Hobbies] CHECK CONSTRAINT [FK_Hobbies_EmployeeId]
GO
ALTER TABLE [HR].[Hobbies]  WITH CHECK ADD  CONSTRAINT [FK_Hobbies_JobApplicationId] FOREIGN KEY([JobApplicationId])
REFERENCES [HR].[JobApplication] ([Id])
GO
ALTER TABLE [HR].[Hobbies] CHECK CONSTRAINT [FK_Hobbies_JobApplicationId]
GO

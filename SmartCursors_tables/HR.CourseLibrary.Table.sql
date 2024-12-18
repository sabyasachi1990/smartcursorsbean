USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[CourseLibrary]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[CourseLibrary](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CourseCode] [nvarchar](30) NOT NULL,
	[CourseName] [nvarchar](200) NULL,
	[CourseCategory] [nvarchar](4000) NOT NULL,
	[Hours] [decimal](5, 2) NOT NULL,
	[DefaultCourseFee] [money] NULL,
	[Funding] [nvarchar](500) NULL,
	[CourseDescription] [nvarchar](max) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[CourseLevel] [bigint] NULL,
 CONSTRAINT [PK_CourseLibrary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[CourseLibrary]  WITH CHECK ADD  CONSTRAINT [FK_CourseLibrary_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[CourseLibrary] CHECK CONSTRAINT [FK_CourseLibrary_Company]
GO

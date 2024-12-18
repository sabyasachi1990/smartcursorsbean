USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Qualification]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Qualification](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[QuaType] [nvarchar](2000) NULL,
	[Qualification] [nvarchar](254) NULL,
	[Institution] [nvarchar](254) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsHighest] [bit] NULL,
	[IsScholarship] [bit] NULL,
	[IsCurrentlyStudying] [bit] NULL,
	[IsOtherQualification] [bit] NULL,
 CONSTRAINT [PK_Qualification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Qualification] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Qualification]  WITH CHECK ADD  CONSTRAINT [FK_Qualification_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Qualification] CHECK CONSTRAINT [FK_Qualification_Employee]
GO

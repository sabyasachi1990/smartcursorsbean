USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[WorkProfile]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[WorkProfile](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[WorkProfileName] [nvarchar](50) NOT NULL,
	[WorkingHoursPerDay] [float] NOT NULL,
	[Monday] [nvarchar](5) NOT NULL,
	[Tuesday] [nvarchar](5) NOT NULL,
	[Wednenday] [nvarchar](5) NOT NULL,
	[Thursday] [nvarchar](5) NOT NULL,
	[Friday] [nvarchar](5) NOT NULL,
	[Saturday] [nvarchar](5) NOT NULL,
	[Sunday] [nvarchar](5) NOT NULL,
	[TotalWorkingDaysPerWeek] [float] NOT NULL,
	[TotalWorkingHoursPerWeek] [float] NOT NULL,
	[IsDefaultProfile] [bit] NOT NULL,
	[IsSuperUserRec] [bit] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
 CONSTRAINT [PK_WorkProfile] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[WorkProfile] ADD  DEFAULT ((0)) FOR [IsDefaultProfile]
GO
ALTER TABLE [HR].[WorkProfile] ADD  DEFAULT ((0)) FOR [IsSuperUserRec]
GO
ALTER TABLE [HR].[WorkProfile]  WITH CHECK ADD  CONSTRAINT [FK_WorkProfile_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[WorkProfile] CHECK CONSTRAINT [FK_WorkProfile_Company]
GO

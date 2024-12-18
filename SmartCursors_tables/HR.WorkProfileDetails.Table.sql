USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[WorkProfileDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[WorkProfileDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[Year] [int] NOT NULL,
	[JanuaryDays] [float] NULL,
	[FebruaryDays] [float] NULL,
	[MarchDays] [float] NULL,
	[AprilDays] [float] NULL,
	[MayDays] [float] NULL,
	[JuneDays] [float] NULL,
	[JulyDays] [float] NULL,
	[AugustDays] [float] NULL,
	[SeptemberDays] [float] NULL,
	[OctoberDays] [float] NULL,
	[NovemberDays] [float] NULL,
	[DecemberDays] [float] NULL,
	[TotalWorkingHoursPerYear] [float] NULL,
	[TotalWorkingDaysPerYear] [float] NULL,
	[IsDefaultProfile] [bit] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
 CONSTRAINT [PK_WorkProfileDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[WorkProfileDetails] ADD  DEFAULT ((0)) FOR [IsDefaultProfile]
GO
ALTER TABLE [HR].[WorkProfileDetails]  WITH CHECK ADD  CONSTRAINT [FK_WorkProfileDetails_WorkProfile] FOREIGN KEY([MasterId])
REFERENCES [HR].[WorkProfile] ([Id])
GO
ALTER TABLE [HR].[WorkProfileDetails] CHECK CONSTRAINT [FK_WorkProfileDetails_WorkProfile]
GO

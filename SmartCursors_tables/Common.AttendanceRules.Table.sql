USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AttendanceRules]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AttendanceRules](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[LateInTime] [int] NOT NULL,
	[LateInType] [nvarchar](10) NULL,
	[LateInTimeType] [nvarchar](10) NULL,
	[LateInStatus] [int] NULL,
	[LateOutTime] [int] NOT NULL,
	[LateOutType] [nvarchar](10) NULL,
	[LateOutTimeType] [nvarchar](10) NULL,
	[LateOutStatus] [int] NULL,
	[PreviousTime] [int] NOT NULL,
	[PreviousType] [nvarchar](10) NULL,
	[PreviousTimeType] [nvarchar](10) NULL,
	[PreviousStatus] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AttendanceRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AttendanceRules] ADD  DEFAULT ((1)) FOR [LateInStatus]
GO
ALTER TABLE [Common].[AttendanceRules] ADD  DEFAULT ((1)) FOR [LateOutStatus]
GO
ALTER TABLE [Common].[AttendanceRules] ADD  DEFAULT ((1)) FOR [PreviousStatus]
GO
ALTER TABLE [Common].[AttendanceRules] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[AttendanceRules]  WITH CHECK ADD  CONSTRAINT [FK_AttendanceRules_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[AttendanceRules] CHECK CONSTRAINT [FK_AttendanceRules_Company]
GO

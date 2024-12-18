USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogItem]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogItem](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](40) NULL,
	[SubType] [nvarchar](500) NULL,
	[ChargeType] [nvarchar](20) NOT NULL,
	[SystemType] [nvarchar](20) NULL,
	[SystemId] [uniqueidentifier] NULL,
	[IsSystem] [bit] NULL,
	[ApplyToAll] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Hours] [decimal](17, 2) NOT NULL,
	[Days] [decimal](17, 2) NOT NULL,
	[FirstHalfFromTime] [time](7) NULL,
	[FirstHalfToTime] [time](7) NULL,
	[FirstHalfTotalHours] [time](7) NULL,
	[SecondHalfFromTime] [time](7) NULL,
	[SecondHalfToTime] [time](7) NULL,
	[SecondHalfTotalHours] [time](7) NULL,
	[IsMain] [bit] NULL,
	[TimeType] [nvarchar](50) NULL,
	[ActualHours] [decimal](17, 2) NULL,
	[SystemSubTypeStatus] [nvarchar](20) NULL,
 CONSTRAINT [PK_TimeLogItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogItem] ADD  DEFAULT ((0)) FOR [IsSystem]
GO
ALTER TABLE [Common].[TimeLogItem] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TimeLogItem] ADD  DEFAULT ((0)) FOR [Hours]
GO
ALTER TABLE [Common].[TimeLogItem] ADD  DEFAULT ((0)) FOR [Days]
GO
ALTER TABLE [Common].[TimeLogItem]  WITH CHECK ADD  CONSTRAINT [FK_TimeLogItem_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TimeLogItem] CHECK CONSTRAINT [FK_TimeLogItem_Company]
GO

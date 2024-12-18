USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Calender]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Calender](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CalendarType] [nvarchar](30) NULL,
	[Name] [nvarchar](200) NULL,
	[FromDateTime] [datetime2](7) NULL,
	[ToDateTime] [datetime2](7) NULL,
	[NoOfHours] [nvarchar](20) NULL,
	[ApplyTo] [nvarchar](20) NULL,
	[ChargeType] [nvarchar](50) NULL,
	[Remarks] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Jurisdiction] [nvarchar](250) NULL,
 CONSTRAINT [PK_Calender] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Calender] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Calender]  WITH CHECK ADD  CONSTRAINT [FK_Calender_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Calender] CHECK CONSTRAINT [FK_Calender_Company]
GO

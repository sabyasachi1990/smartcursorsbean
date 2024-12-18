USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ServiceGroup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ServiceGroup](
	[Id] [bigint] NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[DefaultDays] [int] NULL,
	[bizappservicegrpid] [int] NULL,
	[CursorId] [bigint] NULL,
	[ApprovalName] [varchar](50) NULL,
	[ApprovalDate] [varchar](50) NULL,
	[ApprovalDaysAndMonths] [varchar](20) NULL,
 CONSTRAINT [PK_ServiceGroup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ServiceGroup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ServiceGroup]  WITH CHECK ADD  CONSTRAINT [FK_ServiceGroup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ServiceGroup] CHECK CONSTRAINT [FK_ServiceGroup_Company]
GO

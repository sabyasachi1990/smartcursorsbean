USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[DocumentRecurrence_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[DocumentRecurrence_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TypeOfDocID] [nvarchar](100) NULL,
	[DocSubType] [nvarchar](100) NULL,
	[TypeOfDoc] [nvarchar](100) NULL,
	[RepeatEvery] [bigint] NULL,
	[DaysOrMonths] [nvarchar](10) NULL,
	[Until] [datetime] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_DocumentRecurrence] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[DocumentRecurrence_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[DocumentRecurrence_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_DocumentRecurrence_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[DocumentRecurrence_ToBeDeleted] CHECK CONSTRAINT [FK_DocumentRecurrence_Company]
GO

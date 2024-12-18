USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[Activity]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[Activity](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ActivityType] [nvarchar](20) NULL,
	[ActivitySubject] [nvarchar](100) NULL,
	[Description] [nvarchar](1000) NULL,
	[IsHighPriority] [bit] NULL,
	[DueDate] [datetime2](7) NULL,
	[RemindmeDate] [datetime2](7) NULL,
	[ActivityStatus] [nvarchar](20) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Relation] [nvarchar](20) NULL,
	[RelationId] [uniqueidentifier] NULL,
	[IsPinned] [bit] NULL,
	[PinnedDate] [datetime2](7) NULL,
	[CursorName] [nvarchar](20) NULL,
 CONSTRAINT [PK_Activity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[Activity] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[Activity] ADD  DEFAULT ((0)) FOR [IsPinned]
GO
ALTER TABLE [Widget].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Widget].[Activity] CHECK CONSTRAINT [FK_Activity_Company]
GO

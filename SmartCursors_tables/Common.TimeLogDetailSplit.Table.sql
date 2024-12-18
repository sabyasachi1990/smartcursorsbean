USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TimeLogDetailSplit]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TimeLogDetailSplit](
	[Id] [uniqueidentifier] NOT NULL,
	[TimelogDetailId] [uniqueidentifier] NOT NULL,
	[CaseFeatureId] [uniqueidentifier] NOT NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Hours] [decimal](7, 2) NULL,
 CONSTRAINT [PK_TimeLogDetailSplit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[TimeLogDetailSplit] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TimeLogDetailSplit]  WITH CHECK ADD  CONSTRAINT [PK_TimeLogDetailSplit_CaseFeature] FOREIGN KEY([CaseFeatureId])
REFERENCES [WorkFlow].[CaseFeature] ([Id])
GO
ALTER TABLE [Common].[TimeLogDetailSplit] CHECK CONSTRAINT [PK_TimeLogDetailSplit_CaseFeature]
GO
ALTER TABLE [Common].[TimeLogDetailSplit]  WITH CHECK ADD  CONSTRAINT [PK_TimeLogDetailSplit_TimeLogDetail] FOREIGN KEY([TimelogDetailId])
REFERENCES [Common].[TimeLogDetail] ([Id])
GO
ALTER TABLE [Common].[TimeLogDetailSplit] CHECK CONSTRAINT [PK_TimeLogDetailSplit_TimeLogDetail]
GO

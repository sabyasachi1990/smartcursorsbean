USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Note]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Note](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[LinkTo] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[FeatureName] [nvarchar](100) NULL,
	[FeatureSection] [nvarchar](100) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[WPShortCode] [nvarchar](50) NULL,
	[[DynamicGridId]]] [nvarchar](200) NULL,
	[AccountOrder] [nvarchar](1000) NULL,
	[IsRollForward] [bit] NULL,
	[CategoryId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Notes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[Note] ADD  DEFAULT ((1)) FOR [Status]
GO

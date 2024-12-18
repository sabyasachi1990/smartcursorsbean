USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ChangesHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ChangesHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocType] [nvarchar](200) NULL,
	[CssSprite] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[category] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[UserName] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[EffectiveDateOfChange] [datetime2](7) NULL,
	[ChangesId] [uniqueidentifier] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[IsCurrentstate] [bit] NULL,
	[State] [nvarchar](30) NULL,
	[DocTypeTimeline] [nvarchar](200) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[ProposedDetails] [nvarchar](2000) NULL,
	[DynamicTemplateId] [uniqueidentifier] NULL,
	[DynamictemplatesId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ChangesHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ChangesHistory]  WITH CHECK ADD FOREIGN KEY([DynamicTemplateId])
REFERENCES [Boardroom].[DynamicTemplates] ([Id])
GO
ALTER TABLE [Common].[ChangesHistory]  WITH CHECK ADD FOREIGN KEY([DynamictemplatesId])
REFERENCES [Boardroom].[DynamicTemplates] ([Id])
GO
ALTER TABLE [Common].[ChangesHistory]  WITH CHECK ADD  CONSTRAINT [FK_Company_ChangesHistory] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ChangesHistory] CHECK CONSTRAINT [FK_Company_ChangesHistory]
GO

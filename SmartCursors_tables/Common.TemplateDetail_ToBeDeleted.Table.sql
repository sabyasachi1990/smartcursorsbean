USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](254) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[InputEntity] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TemplateDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateDetail_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_TemplateDetail_TemplateMaster] FOREIGN KEY([MasterId])
REFERENCES [Common].[TemplateMaster_ToBeDeleted] ([Id])
GO
ALTER TABLE [Common].[TemplateDetail_ToBeDeleted] CHECK CONSTRAINT [FK_TemplateDetail_TemplateMaster]
GO

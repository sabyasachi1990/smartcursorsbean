USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Template]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Template](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Code] [nvarchar](max) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FromEmailId] [nvarchar](100) NULL,
	[CCEmailIds] [nvarchar](500) NULL,
	[BCCEmailIds] [nvarchar](500) NULL,
	[TemplateType] [nvarchar](30) NULL,
	[TempletContent] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Subject] [nvarchar](256) NULL,
	[TemplateMenu] [nvarchar](100) NULL,
	[ToEmailId] [nvarchar](500) NULL,
	[IsUnique] [bit] NULL,
	[LeadCategory] [nvarchar](50) NULL,
	[CursorName] [nvarchar](50) NULL,
	[IsLandscape] [bit] NULL,
	[IsCreated] [bit] NULL,
	[Jurisdiction] [nvarchar](500) NULL,
 CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[Template] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Template] ADD  DEFAULT ((0)) FOR [IsUnique]
GO
ALTER TABLE [Common].[Template] ADD  DEFAULT ((0)) FOR [IsLandscape]
GO
ALTER TABLE [Common].[Template]  WITH CHECK ADD  CONSTRAINT [FK_Template_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Template] CHECK CONSTRAINT [FK_Template_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateSetUp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Action] [nvarchar](254) NOT NULL,
	[TemplateSetName] [nvarchar](254) NOT NULL,
	[Category] [nvarchar](500) NOT NULL,
	[IsDefult] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_TemplateSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateSetUp] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateSetUp]  WITH CHECK ADD  CONSTRAINT [FK_TemplateSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TemplateSetUp] CHECK CONSTRAINT [FK_TemplateSetUp_Company]
GO

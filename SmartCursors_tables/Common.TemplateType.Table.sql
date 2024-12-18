USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TemplateType]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TemplateType](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](254) NULL,
	[Status] [int] NULL,
	[Actions] [nvarchar](max) NULL,
	[IsSystem] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsServiceCompany] [bit] NULL,
	[ISAllowDuplicates] [bit] NULL,
	[Istemp] [bit] NULL,
 CONSTRAINT [PK_TemplateType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[TemplateType] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TemplateType]  WITH CHECK ADD  CONSTRAINT [FK_TemplateType_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TemplateType] CHECK CONSTRAINT [FK_TemplateType_Company]
GO
ALTER TABLE [Common].[TemplateType]  WITH CHECK ADD  CONSTRAINT [FK_TemplateType_Modulemaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[TemplateType] CHECK CONSTRAINT [FK_TemplateType_Modulemaster]
GO

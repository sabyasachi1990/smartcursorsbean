USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GenericTemplate]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GenericTemplate](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TemplateTypeId] [uniqueidentifier] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Code] [nvarchar](max) NULL,
	[TempletContent] [nvarchar](max) NULL,
	[IsSystem] [bit] NULL,
	[IsFooterExist] [bit] NULL,
	[IsHeaderExist] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Category] [nvarchar](100) NULL,
	[Conditions] [nvarchar](600) NULL,
	[IsUsed] [bit] NULL,
	[FromEmailId] [nvarchar](200) NULL,
	[ToEmailId] [nvarchar](1000) NULL,
	[CCEmailIds] [varchar](500) NULL,
	[BCCEmailIds] [varchar](500) NULL,
	[TemplateType] [varchar](50) NULL,
	[Subject] [nvarchar](256) NULL,
	[IsPartnerTemplate] [bit] NULL,
	[IsDefultTemplate] [bit] NULL,
	[Isthisemailtemplate] [bit] NULL,
	[IsLandscape] [bit] NULL,
	[CursorName] [nvarchar](200) NULL,
	[ServiceCompanyIds] [nvarchar](2000) NULL,
	[ServiceCompanyNames] [nvarchar](2000) NULL,
	[IsEnableServiceEntities] [bit] NULL,
	[ISAllowDuplicates] [bit] NULL,
	[Jurisdiction] [nvarchar](250) NULL,
 CONSTRAINT [PK_GenericTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[GenericTemplate] ADD  DEFAULT ((0)) FOR [IsSystem]
GO
ALTER TABLE [Common].[GenericTemplate] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[GenericTemplate]  WITH CHECK ADD  CONSTRAINT [FK_GenericTemplate_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[GenericTemplate] CHECK CONSTRAINT [FK_GenericTemplate_Company]
GO
ALTER TABLE [Common].[GenericTemplate]  WITH CHECK ADD  CONSTRAINT [FK_GenericTemplate_TemplateType] FOREIGN KEY([TemplateTypeId])
REFERENCES [Common].[TemplateType] ([Id])
GO
ALTER TABLE [Common].[GenericTemplate] CHECK CONSTRAINT [FK_GenericTemplate_TemplateType]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ControlCodeCategory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ControlCodeCategory](
	[Id] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ControlCodeCategoryCode] [nvarchar](100) NOT NULL,
	[ControlCodeCategoryDescription] [nvarchar](100) NOT NULL,
	[DataType] [nvarchar](10) NULL,
	[Format] [nvarchar](20) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ModuleNamesUsing] [nvarchar](1000) NULL,
	[DefaultValue] [nvarchar](100) NULL,
 CONSTRAINT [PK_ControlCodeCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ControlCodeCategory] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ControlCodeCategory]  WITH CHECK ADD  CONSTRAINT [FK_ControlCodeCategory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[ControlCodeCategory] CHECK CONSTRAINT [FK_ControlCodeCategory_Company]
GO

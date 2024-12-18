USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ControlCode]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ControlCode](
	[Id] [bigint] NOT NULL,
	[ControlCategoryId] [bigint] NOT NULL,
	[CodeKey] [nvarchar](4000) NOT NULL,
	[CodeValue] [nvarchar](4000) NOT NULL,
	[IsSystem] [nvarchar](10) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsDefault] [bit] NULL,
	[ModuleNamesUsing] [nvarchar](1000) NULL,
	[Jurisdiction] [nvarchar](250) NULL,
 CONSTRAINT [PK_ControlCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ControlCode] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ControlCode] ADD  DEFAULT ((1)) FOR [IsDefault]
GO
ALTER TABLE [Common].[ControlCode]  WITH CHECK ADD  CONSTRAINT [FK_ControlCode_ControlCategory] FOREIGN KEY([ControlCategoryId])
REFERENCES [Common].[ControlCodeCategory] ([Id])
GO
ALTER TABLE [Common].[ControlCode] CHECK CONSTRAINT [FK_ControlCode_ControlCategory]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Auth].[Role]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Auth].[Role](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[ModuleMasterId] [bigint] NULL,
	[Status] [int] NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[IsSystem] [bit] NULL,
	[BackgroundColor] [nvarchar](50) NULL,
	[CursorIcon] [nvarchar](50) NULL,
	[IsPartner] [bit] NULL,
	[TempId] [uniqueidentifier] NULL,
	[CursorStatus] [bit] NOT NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Auth].[Role] ADD  CONSTRAINT [default_CursorStatus]  DEFAULT ((0)) FOR [CursorStatus]
GO
ALTER TABLE [Auth].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Auth].[Role] CHECK CONSTRAINT [FK_Role_Company]
GO
ALTER TABLE [Auth].[Role]  WITH CHECK ADD  CONSTRAINT [FK_Role_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Auth].[Role] CHECK CONSTRAINT [FK_Role_ModuleMaster]
GO

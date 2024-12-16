USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[StateChange]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[StateChange](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Type] [nvarchar](20) NULL,
	[FromState] [nvarchar](100) NULL,
	[ToStates] [nvarchar](256) NULL,
	[IsTab] [bit] NULL,
	[PermissionKey] [nvarchar](500) NULL,
	[IsForPermissions] [bit] NULL,
	[TostatesLU] [nvarchar](500) NULL,
	[DonNotToStates] [nvarchar](256) NULL,
 CONSTRAINT [PK_StateChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[StateChange]  WITH CHECK ADD  CONSTRAINT [Fk_StateChange_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[StateChange] CHECK CONSTRAINT [Fk_StateChange_CompanyId]
GO

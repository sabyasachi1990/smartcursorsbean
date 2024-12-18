USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[EngagementUsers]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[EngagementUsers](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[IsAudit] [bit] NOT NULL,
	[IsTax] [bit] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
	[RoleId] [uniqueidentifier] NULL,
	[TaxRoleId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EngagementUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[EngagementUsers] ADD  DEFAULT ((0)) FOR [IsAudit]
GO
ALTER TABLE [Common].[EngagementUsers] ADD  DEFAULT ((0)) FOR [IsTax]
GO
ALTER TABLE [Common].[EngagementUsers] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[EngagementUsers]  WITH CHECK ADD  CONSTRAINT [FK_EngagementUsers_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[EngagementUsers] CHECK CONSTRAINT [FK_EngagementUsers_Company]
GO
ALTER TABLE [Common].[EngagementUsers]  WITH CHECK ADD  CONSTRAINT [FK_EngagementUsers_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [Common].[EngagementUsers] CHECK CONSTRAINT [FK_EngagementUsers_CompanyUser]
GO

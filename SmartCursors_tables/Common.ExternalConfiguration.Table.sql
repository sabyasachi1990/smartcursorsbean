USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ExternalConfiguration]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ExternalConfiguration](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TenantId] [nvarchar](500) NULL,
	[ClientId] [nvarchar](500) NULL,
	[Secret] [nvarchar](500) NULL,
	[AdminEmail] [nvarchar](500) NULL,
	[SkipConfirmationPage] [bit] NOT NULL,
	[ExternalType] [nvarchar](500) NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[DomainName] [nvarchar](254) NULL,
	[IsSharePointEnabled] [bit] NOT NULL,
	[IsOutlookEnabled] [bit] NULL,
	[IsPreparation] [bit] NOT NULL,
	[MigrationStatus] [nvarchar](50) NULL,
	[PermissionsStatus] [nvarchar](40) NULL,
	[PublishableKey] [nvarchar](max) NULL,
	[IsRedirectSP] [bit] NULL,
	[RedirectCursors] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[ExternalConfiguration] ADD  DEFAULT ((0)) FOR [IsSharePointEnabled]
GO
ALTER TABLE [Common].[ExternalConfiguration] ADD  DEFAULT ((0)) FOR [IsPreparation]
GO

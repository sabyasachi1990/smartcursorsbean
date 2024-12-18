USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroConnection]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroConnection](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ConnectionId] [nvarchar](100) NULL,
	[AuthEventId] [nvarchar](1000) NULL,
	[TenantId] [nvarchar](1000) NULL,
	[TenantType] [nvarchar](1000) NULL,
	[TenantName] [nvarchar](1000) NULL,
	[CreatedDateUtc] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[UpdatedDateUtc] [datetime2](7) NULL,
 CONSTRAINT [PK_XeroConnections] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

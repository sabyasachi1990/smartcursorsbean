USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditRole_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditRole_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Remarks] [nvarchar](1000) NULL,
	[IsSystem] [bit] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_AuditRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditRole_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_AuditRole_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[AuditRole_ToBeDeleted] CHECK CONSTRAINT [FK_AuditRole_Company]
GO

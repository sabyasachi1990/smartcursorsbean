USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditCompanyContact]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditCompanyContact](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Communication] [nvarchar](1000) NULL,
	[Website] [nvarchar](1000) NULL,
	[OtherDesignation] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AuditCompanyContact] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditCompanyContact] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AuditCompanyContact]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyContact_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyContact] CHECK CONSTRAINT [FK_AuditCompanyContact_AuditCompany]
GO
ALTER TABLE [Audit].[AuditCompanyContact]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyContact_Contact] FOREIGN KEY([ContactId])
REFERENCES [Common].[Contact] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyContact] CHECK CONSTRAINT [FK_AuditCompanyContact_Contact]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditMenuHelpLinks]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditMenuHelpLinks](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyMenuMasterId] [uniqueidentifier] NOT NULL,
	[HelpLinkContent] [nvarchar](max) NULL,
 CONSTRAINT [PK_AuditMenuHelpLinks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditMenuHelpLinks]  WITH CHECK ADD  CONSTRAINT [FK_AuditMenuHelpLinks_AuditCompanyMenuMaster] FOREIGN KEY([AuditCompanyMenuMasterId])
REFERENCES [Audit].[AuditCompanyMenuMaster] ([Id])
GO
ALTER TABLE [Audit].[AuditMenuHelpLinks] CHECK CONSTRAINT [FK_AuditMenuHelpLinks_AuditCompanyMenuMaster]
GO

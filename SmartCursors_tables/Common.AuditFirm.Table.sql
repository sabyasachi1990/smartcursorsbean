USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AuditFirm]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AuditFirm](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[FirmName] [nvarchar](50) NULL,
	[ShortName] [nvarchar](10) NULL,
	[RegistrationNumber] [nvarchar](10) NULL,
	[PhoneNumber] [bigint] NULL,
	[Website] [nvarchar](50) NULL,
	[Address1] [nvarchar](256) NULL,
	[Address2] [nvarchar](256) NULL,
	[City] [nvarchar](20) NULL,
	[Country] [nvarchar](20) NULL,
	[PIN] [bigint] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AuditFirm] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AuditFirm] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[AuditFirm]  WITH CHECK ADD  CONSTRAINT [FK_AuditFirm_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[AuditFirm] CHECK CONSTRAINT [FK_AuditFirm_Company]
GO

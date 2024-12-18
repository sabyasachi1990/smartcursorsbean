USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[FileHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[FileHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[BatchId] [nvarchar](50) NOT NULL,
	[Year] [bigint] NOT NULL,
	[ServiceEntity] [nvarchar](200) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[SubCompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](400) NOT NULL,
	[OrganisationIdNo] [nvarchar](400) NOT NULL,
	[AuthorisedPersonDesignation] [nvarchar](400) NOT NULL,
	[AuthorizedPersonName] [nvarchar](400) NOT NULL,
	[OrganisationIdType] [nvarchar](300) NOT NULL,
	[IR8AHRSetupId] [uniqueidentifier] NOT NULL,
	[CreatedBy] [nvarchar](300) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[FileName] [nvarchar](300) NOT NULL,
	[FilePath] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_FileHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[FileHistory]  WITH CHECK ADD  CONSTRAINT [FK_FileHistory_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[FileHistory] CHECK CONSTRAINT [FK_FileHistory_Company]
GO
ALTER TABLE [HR].[FileHistory]  WITH CHECK ADD  CONSTRAINT [FK_FileHistory_IR8AHRSetUp] FOREIGN KEY([IR8AHRSetupId])
REFERENCES [HR].[IR8AHRSetUp] ([Id])
GO
ALTER TABLE [HR].[FileHistory] CHECK CONSTRAINT [FK_FileHistory_IR8AHRSetUp]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Asset]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Asset](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Description] [nvarchar](100) NULL,
	[LoanDate] [datetime2](7) NULL,
	[ReturnDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[MongoFileId] [nvarchar](max) NULL,
	[AssetSetupDetailsId] [uniqueidentifier] NULL,
	[Remarks] [varchar](1000) NULL,
 CONSTRAINT [PK_Asset] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Asset] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_AssetSetupDetails] FOREIGN KEY([AssetSetupDetailsId])
REFERENCES [HR].[AssetSetupDetails] ([Id])
GO
ALTER TABLE [HR].[Asset] CHECK CONSTRAINT [FK_Asset_AssetSetupDetails]
GO
ALTER TABLE [HR].[Asset]  WITH CHECK ADD  CONSTRAINT [FK_Asset_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Asset] CHECK CONSTRAINT [FK_Asset_Employee]
GO

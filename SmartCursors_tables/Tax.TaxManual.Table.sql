USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxManual]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxManual](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[CompanyId] [bigint] NOT NULL,
	[Version] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TaxManual] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxManual]  WITH CHECK ADD  CONSTRAINT [FK_TaxManual_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TaxManual] CHECK CONSTRAINT [FK_TaxManual_Company]
GO

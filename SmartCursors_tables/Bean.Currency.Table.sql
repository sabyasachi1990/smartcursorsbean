USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Currency]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Currency](
	[Id] [bigint] NOT NULL,
	[Code] [nvarchar](5) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[DefaultValue] [nvarchar](20) NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[Currency] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[Currency]  WITH CHECK ADD  CONSTRAINT [FK_Currency_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Currency] CHECK CONSTRAINT [FK_Currency_Company]
GO

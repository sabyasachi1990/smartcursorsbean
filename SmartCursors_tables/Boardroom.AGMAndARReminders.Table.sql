USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMAndARReminders]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMAndARReminders](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Duration] [nvarchar](100) NULL,
	[IsEmail] [bit] NULL,
	[IsLetter] [bit] NULL,
	[Operator] [nvarchar](20) NULL,
	[CalculationBasedOn] [nvarchar](50) NULL,
	[Period] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[TemplateId] [uniqueidentifier] NULL,
	[TemplateMode] [nvarchar](10) NULL,
 CONSTRAINT [Pk_AGMAndARReminders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMAndARReminders]  WITH CHECK ADD  CONSTRAINT [FK_Company_AGMAndARReminders] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[AGMAndARReminders] CHECK CONSTRAINT [FK_Company_AGMAndARReminders]
GO

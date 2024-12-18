USE [SmartCursorSTG]
GO
/****** Object:  Table [DR].[FinanceCompanyEngagement]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DR].[FinanceCompanyEngagement](
	[Id] [uniqueidentifier] NOT NULL,
	[FinanceCompanyId] [uniqueidentifier] NOT NULL,
	[ProjectName] [nvarchar](100) NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_FinanceCompanyEngagement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [DR].[FinanceCompanyEngagement] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [DR].[FinanceCompanyEngagement]  WITH CHECK ADD  CONSTRAINT [FK_FinanceCompanyEngagement_FinanceCompany] FOREIGN KEY([FinanceCompanyId])
REFERENCES [DR].[FinanceCompany] ([Id])
GO
ALTER TABLE [DR].[FinanceCompanyEngagement] CHECK CONSTRAINT [FK_FinanceCompanyEngagement_FinanceCompany]
GO

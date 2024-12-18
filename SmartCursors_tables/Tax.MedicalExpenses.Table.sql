USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[MedicalExpenses]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[MedicalExpenses](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxCompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[EligibleExpenses] [money] NOT NULL,
	[AddbackAmount] [money] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](256) NULL,
 CONSTRAINT [PK_MedicalExpenses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[MedicalExpenses] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[MedicalExpenses]  WITH CHECK ADD  CONSTRAINT [FK_Company_MedicalExpenses] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[MedicalExpenses] CHECK CONSTRAINT [FK_Company_MedicalExpenses]
GO
ALTER TABLE [Tax].[MedicalExpenses]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyEngagement_MedicalExpenses] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[MedicalExpenses] CHECK CONSTRAINT [FK_TaxCompanyEngagement_MedicalExpenses]
GO

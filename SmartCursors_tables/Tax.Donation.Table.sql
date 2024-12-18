USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Donation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Donation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TaxCompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[DonationDate] [datetime2](7) NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Cost] [money] NULL,
	[IsAllowedUnderIPC] [bit] NOT NULL,
	[IPCMultiplier] [int] NULL,
	[EnhancedAllowanceOrDeduction] [money] NULL,
	[TotalDeduction] [money] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Donation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[Donation] ADD  DEFAULT ((1)) FOR [IsAllowedUnderIPC]
GO
ALTER TABLE [Tax].[Donation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[Donation]  WITH CHECK ADD  CONSTRAINT [FK_Company_Donation] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[Donation] CHECK CONSTRAINT [FK_Company_Donation]
GO
ALTER TABLE [Tax].[Donation]  WITH CHECK ADD  CONSTRAINT [FK_Company_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[Donation] CHECK CONSTRAINT [FK_Company_TaxCompanyEngagement]
GO

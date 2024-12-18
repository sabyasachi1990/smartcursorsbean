USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[Campaign]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[Campaign](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](254) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CampaignOwner] [nvarchar](254) NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[CampaignType] [nvarchar](50) NULL,
	[CampaignStatus] [nvarchar](20) NULL,
	[BudgetedCost] [money] NULL,
	[ActualCost] [money] NULL,
	[ExpectedLeads] [int] NULL,
	[LeadsGenerated] [int] NULL,
	[Description] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Campaign] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[Campaign] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[Campaign]  WITH CHECK ADD  CONSTRAINT [FK_Campaign_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[Campaign] CHECK CONSTRAINT [FK_Campaign_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityStatusChange]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityStatusChange](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[State] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_OpportunityStatusChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_AccountStatusChange_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityStatusChange] CHECK CONSTRAINT [FK_AccountStatusChange_Opportunity]
GO
ALTER TABLE [ClientCursor].[OpportunityStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityStatusChange_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityStatusChange] CHECK CONSTRAINT [FK_OpportunityStatusChange_Company]
GO

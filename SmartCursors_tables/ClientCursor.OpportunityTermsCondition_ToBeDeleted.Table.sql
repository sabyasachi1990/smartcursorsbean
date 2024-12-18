USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityTermsCondition_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityTermsCondition_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](254) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[InputEntity] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_OpportunityTermsCondition] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityTermsCondition_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[OpportunityTermsCondition_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityTermsCondition_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityTermsCondition_ToBeDeleted] CHECK CONSTRAINT [FK_OpportunityTermsCondition_Opportunity]
GO

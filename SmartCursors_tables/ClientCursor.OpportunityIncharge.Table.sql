USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[OpportunityIncharge]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[OpportunityIncharge](
	[Id] [uniqueidentifier] NOT NULL,
	[OpportunityId] [uniqueidentifier] NOT NULL,
	[IsPrimary] [bit] NULL,
	[RecOrder] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[CompanyUserId] [bigint] NULL,
 CONSTRAINT [PK_OpportunityIncharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[OpportunityIncharge] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[OpportunityIncharge]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityIncharge_CompanyUser_Id] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityIncharge] CHECK CONSTRAINT [FK_OpportunityIncharge_CompanyUser_Id]
GO
ALTER TABLE [ClientCursor].[OpportunityIncharge]  WITH CHECK ADD  CONSTRAINT [FK_OpportunityIncharge_Opportunity] FOREIGN KEY([OpportunityId])
REFERENCES [ClientCursor].[Opportunity] ([Id])
GO
ALTER TABLE [ClientCursor].[OpportunityIncharge] CHECK CONSTRAINT [FK_OpportunityIncharge_Opportunity]
GO

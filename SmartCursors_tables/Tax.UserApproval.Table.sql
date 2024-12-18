USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[UserApproval]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[UserApproval](
	[ID] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](15) NULL,
	[Screen] [nvarchar](50) NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[UserCode] [nvarchar](10) NULL,
	[DateCode] [nvarchar](10) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_UserApproval] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[UserApproval] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[UserApproval]  WITH CHECK ADD  CONSTRAINT [Fk_UserApproval_EngagementId] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[UserApproval] CHECK CONSTRAINT [Fk_UserApproval_EngagementId]
GO

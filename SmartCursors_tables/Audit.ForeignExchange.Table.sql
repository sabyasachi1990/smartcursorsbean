USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ForeignExchange]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ForeignExchange](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementID] [uniqueidentifier] NULL,
	[NA] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignExchange] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ForeignExchange] ADD  DEFAULT ((0)) FOR [NA]
GO
ALTER TABLE [Audit].[ForeignExchange] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[ForeignExchange]  WITH CHECK ADD  CONSTRAINT [FK_ForeignExchange_AuditCompanyEngagement] FOREIGN KEY([EngagementID])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[ForeignExchange] CHECK CONSTRAINT [FK_ForeignExchange_AuditCompanyEngagement]
GO

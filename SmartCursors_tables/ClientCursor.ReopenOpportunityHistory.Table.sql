USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[ReopenOpportunityHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[ReopenOpportunityHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[TranactionId] [uniqueidentifier] NOT NULL,
	[AccountLead] [nvarchar](500) NULL,
	[ReopeningOn] [datetime2](7) NULL,
	[ServiceGroup] [nvarchar](250) NULL,
	[ServiceName] [nvarchar](250) NULL,
	[ServiceCode] [nvarchar](250) NULL,
	[ServiceEntity] [nvarchar](250) NULL,
	[ServiceNature] [nvarchar](250) NULL,
	[FeeTypes] [nvarchar](250) NULL,
	[Fees] [money] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](250) NULL,
	[Status] [int] NULL,
	[ExceptionRemarks] [nvarchar](1000) NULL,
	[State] [nvarchar](250) NULL,
	[CreatedId] [uniqueidentifier] NULL,
	[QuotationId] [uniqueidentifier] NULL,
	[QuotedId] [uniqueidentifier] NULL,
	[WonId] [uniqueidentifier] NULL,
	[AzurePath] [nvarchar](max) NULL,
	[NotificationSent] [bit] NULL,
	[TargetedRecovery] [nvarchar](256) NULL,
	[OpportunityNumber] [nvarchar](256) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

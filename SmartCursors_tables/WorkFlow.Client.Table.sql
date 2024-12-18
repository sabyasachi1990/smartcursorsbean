USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Client]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Client](
	[Id] [uniqueidentifier] NOT NULL,
	[SystemRefNo] [nvarchar](50) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ClientTypeId] [bigint] NULL,
	[ClientIdTypeId] [bigint] NULL,
	[ClientIdNo] [nvarchar](50) NULL,
	[Communication] [nvarchar](1000) NULL,
	[IdtypeId] [bigint] NULL,
	[TermsOfPaymentId] [bigint] NULL,
	[Industry] [nvarchar](100) NULL,
	[ClientSourceId] [bigint] NULL,
	[Source] [nvarchar](100) NULL,
	[SourceId] [nvarchar](100) NULL,
	[SourceName] [nvarchar](100) NULL,
	[SourceRemarks] [nvarchar](100) NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[FinancialYearEnd] [datetime2](7) NULL,
	[CountryOfIncorporation] [nvarchar](100) NULL,
	[ClientStatus] [nvarchar](20) NULL,
	[PrincipalActivities] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsLocal] [bit] NULL,
	[AccountId] [uniqueidentifier] NULL,
	[IsCcEnable] [bit] NULL,
	[SyncEntityId] [uniqueidentifier] NULL,
	[SyncEntityStatus] [nvarchar](100) NULL,
	[SyncEntityDate] [datetime2](7) NULL,
	[SyncEntityRemarks] [nvarchar](max) NULL,
	[SyncAccountId] [uniqueidentifier] NULL,
	[SyncAccountStatus] [varchar](50) NULL,
	[SyncAccountRemarks] [nvarchar](max) NULL,
	[SyncAccountDate] [datetime2](7) NULL,
	[IsCreated] [bit] NULL,
	[XeroContactId] [uniqueidentifier] NULL,
	[ParticipantPeppolId] [nvarchar](50) NULL,
	[IndustryCode] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Client] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_AccountSource] FOREIGN KEY([ClientSourceId])
REFERENCES [Common].[AccountSource_ToBeDeleted] ([Id])
GO
ALTER TABLE [WorkFlow].[Client] CHECK CONSTRAINT [FK_Client_AccountSource]
GO
ALTER TABLE [WorkFlow].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_AccountType] FOREIGN KEY([ClientTypeId])
REFERENCES [Common].[AccountType] ([Id])
GO
ALTER TABLE [WorkFlow].[Client] CHECK CONSTRAINT [FK_Client_AccountType]
GO
ALTER TABLE [WorkFlow].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[Client] CHECK CONSTRAINT [FK_Client_Company]
GO
ALTER TABLE [WorkFlow].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_IdType] FOREIGN KEY([IdtypeId])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [WorkFlow].[Client] CHECK CONSTRAINT [FK_Client_IdType]
GO
ALTER TABLE [WorkFlow].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_TermsOfPayment] FOREIGN KEY([TermsOfPaymentId])
REFERENCES [Common].[TermsOfPayment] ([Id])
GO
ALTER TABLE [WorkFlow].[Client] CHECK CONSTRAINT [FK_Client_TermsOfPayment]
GO

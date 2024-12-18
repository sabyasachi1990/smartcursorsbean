USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AccountPolicy]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AccountPolicy](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[PolicyName] [nvarchar](4000) NULL,
	[PolicyTemplate] [nvarchar](max) NULL,
	[IsChecked] [bit] NULL,
	[IsSytem] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Section] [bigint] NULL,
	[PolicyNameId] [uniqueidentifier] NULL,
	[IsRollForward] [bit] NULL,
	[SectionName] [nvarchar](400) NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[FSTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AccountPolicy] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[AccountPolicy] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Audit].[AccountPolicy] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AccountPolicy]  WITH CHECK ADD  CONSTRAINT [FK_AccountPolicy_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[AccountPolicy] CHECK CONSTRAINT [FK_AccountPolicy_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyNameHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyNameHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[ProposedEntityName] [nvarchar](100) NOT NULL,
	[ProposedSuffix] [nvarchar](50) NOT NULL,
	[State] [nvarchar](15) NOT NULL,
	[IsPricipalApproval] [bit] NOT NULL,
	[IsCharityStatus] [bit] NOT NULL,
	[Transaction_Number] [nvarchar](20) NULL,
	[EffectiveFromDateOfChange] [datetime2](7) NULL,
	[EffectiveToDateOfChange] [datetime2](7) NOT NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsApprovalRegistrar] [bit] NULL,
	[DateOfLodged] [datetime] NULL,
	[ApprovedDate] [datetime] NULL,
	[ReasonForCancellation] [nvarchar](500) NULL,
	[IsUpdate] [bit] NULL,
 CONSTRAINT [PK_CompanyNameHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyNameHistory] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[CompanyNameHistory] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyNameHistory]  WITH CHECK ADD  CONSTRAINT [FK_CompanyNameHistory_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Common].[CompanyNameHistory] CHECK CONSTRAINT [FK_CompanyNameHistory_EntityDetail]
GO

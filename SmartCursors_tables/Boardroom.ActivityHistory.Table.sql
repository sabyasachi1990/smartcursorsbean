USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[ActivityHistory]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[ActivityHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityActivityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ProposedPASSICCode] [nvarchar](5) NOT NULL,
	[ProposedPrimaryActivity] [nvarchar](300) NOT NULL,
	[ProposedPADescription] [nvarchar](100) NULL,
	[ProposedSASSICCode] [nvarchar](5) NULL,
	[ProposedSecondaryActivity] [nvarchar](300) NULL,
	[ProposedSADescription] [nvarchar](100) NULL,
	[IsPricipalApproval] [bit] NULL,
	[State] [nvarchar](15) NOT NULL,
	[EffectiveFromDateOfChange] [datetime2](7) NOT NULL,
	[EffectiveToDateOfChange] [datetime2](7) NOT NULL,
	[RecOrder] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsUpdate] [bit] NULL,
	[DateOfApproval] [datetime2](7) NULL,
	[DateOfLodged] [datetime2](7) NULL,
	[ReasonForCancellation] [nvarchar](500) NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ActivityHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[ActivityHistory]  WITH CHECK ADD  CONSTRAINT [FK_ActivityHistory_EntityActivity] FOREIGN KEY([EntityActivityId])
REFERENCES [Boardroom].[EntityActivity] ([Id])
GO
ALTER TABLE [Boardroom].[ActivityHistory] CHECK CONSTRAINT [FK_ActivityHistory_EntityActivity]
GO
ALTER TABLE [Boardroom].[ActivityHistory]  WITH CHECK ADD  CONSTRAINT [FK_ActivityHistory_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[ActivityHistory] CHECK CONSTRAINT [FK_ActivityHistory_EntityDetail]
GO

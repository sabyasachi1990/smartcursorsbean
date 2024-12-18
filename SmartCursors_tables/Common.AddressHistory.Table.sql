USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AddressHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AddressHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[ProposedIsFiveHours] [bit] NULL,
	[ProposedNoOfHours] [nvarchar](15) NULL,
	[State] [nvarchar](15) NOT NULL,
	[TypeOfNotice] [nvarchar](25) NULL,
	[DateOfOpening] [datetime2](7) NULL,
	[Type] [nvarchar](50) NOT NULL,
	[EffectiveFromDateOfChange] [datetime2](7) NOT NULL,
	[EffectiveToDateOfChange] [datetime2](7) NOT NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsUpdate] [bit] NULL,
	[ReasonForCancellation] [nvarchar](500) NULL,
	[DateOfapproval] [datetime2](7) NULL,
	[DateOfLodged] [datetime2](7) NULL,
 CONSTRAINT [PK_AddressHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AddressHistory] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[AddressHistory] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[AddressHistory]  WITH CHECK ADD  CONSTRAINT [FK_AddressHistory_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Common].[AddressHistory] CHECK CONSTRAINT [FK_AddressHistory_EntityDetail]
GO

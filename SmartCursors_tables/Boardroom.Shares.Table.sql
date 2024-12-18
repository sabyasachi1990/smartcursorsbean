USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Shares]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Shares](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EntityId] [uniqueidentifier] NULL,
	[Type] [nvarchar](100) NULL,
	[RefNo] [nvarchar](15) NULL,
	[Currency] [nvarchar](50) NOT NULL,
	[SharePrice] [decimal](10, 2) NOT NULL,
	[SharePayable] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[TransactionType] [nvarchar](100) NOT NULL,
	[ShareType] [nvarchar](100) NOT NULL,
	[Class] [nvarchar](100) NOT NULL,
	[Date] [datetime2](7) NULL,
	[ModeofAllotment] [nvarchar](100) NOT NULL,
	[NatureofAllotment] [nvarchar](500) NOT NULL,
	[NoofShares] [int] NOT NULL,
	[AmtofIssuedShareCapital] [decimal](10, 2) NOT NULL,
	[AmtofPaidUpShareCapital] [decimal](10, 2) NOT NULL,
	[IsSubClassesAvailable] [bit] NOT NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Shares] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Shares] ADD  DEFAULT (getdate()) FOR [Date]
GO
ALTER TABLE [Boardroom].[Shares] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[Shares] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[Shares]  WITH CHECK ADD  CONSTRAINT [FK_Shares_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Shares] CHECK CONSTRAINT [FK_Shares_Company]
GO
ALTER TABLE [Boardroom].[Shares]  WITH CHECK ADD  CONSTRAINT [FK_Shares_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Shares] CHECK CONSTRAINT [FK_Shares_EntityDetail]
GO

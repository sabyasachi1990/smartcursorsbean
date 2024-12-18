USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[SharesDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[SharesDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[SharesId] [uniqueidentifier] NOT NULL,
	[GenericContactId] [uniqueidentifier] NOT NULL,
	[Currency] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Amount] [decimal](10, 2) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[ShareCertificate] [int] NOT NULL,
	[NoofShares] [bigint] NOT NULL,
	[PriceperShare] [decimal](10, 2) NOT NULL,
	[ShareGroup] [nvarchar](500) NULL,
	[SharesheldinTrust] [bit] NOT NULL,
	[NameoftheTrust] [nvarchar](500) NOT NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_SharesDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[SharesDetail] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[SharesDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[SharesDetail]  WITH CHECK ADD  CONSTRAINT [FK_SharesDetail_GenericContact] FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[SharesDetail] CHECK CONSTRAINT [FK_SharesDetail_GenericContact]
GO
ALTER TABLE [Boardroom].[SharesDetail]  WITH CHECK ADD  CONSTRAINT [FK_SharesDetail_Shares] FOREIGN KEY([SharesId])
REFERENCES [Boardroom].[Shares] ([Id])
GO
ALTER TABLE [Boardroom].[SharesDetail] CHECK CONSTRAINT [FK_SharesDetail_Shares]
GO

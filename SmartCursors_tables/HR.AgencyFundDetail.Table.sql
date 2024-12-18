USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AgencyFundDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AgencyFundDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[AgencyFundId] [uniqueidentifier] NOT NULL,
	[WageFrom] [money] NOT NULL,
	[WageTo] [money] NOT NULL,
	[Contribution] [money] NOT NULL,
	[EffectiveFrom] [datetime2](7) NOT NULL,
	[MosqueandReligiouscomponent] [money] NULL,
	[Mendakicomponent] [money] NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[IsDummyEffectiveTo] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AgencyFundDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AgencyFundDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[AgencyFundDetail]  WITH CHECK ADD  CONSTRAINT [FK_AgencyFundDetail_AgencyFund] FOREIGN KEY([AgencyFundId])
REFERENCES [HR].[AgencyFund] ([Id])
GO
ALTER TABLE [HR].[AgencyFundDetail] CHECK CONSTRAINT [FK_AgencyFundDetail_AgencyFund]
GO

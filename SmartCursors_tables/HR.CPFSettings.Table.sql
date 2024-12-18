USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[CPFSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[CPFSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ContributionFor] [nvarchar](256) NULL,
	[AgeFrom] [int] NULL,
	[AgeTo] [int] NULL,
	[TotalWageFrom] [money] NULL,
	[TotalWageTo] [money] NULL,
	[EmprTotalWageRate] [money] NULL,
	[EmpDifferentialsWageAmt] [money] NULL,
	[EmprDifferentialsWageAmt] [money] NULL,
	[EmpDifferentialsWageRate] [money] NULL,
	[EmprDifferentialsWageRate] [money] NULL,
	[EmpOrdinaryWageRate] [money] NULL,
	[EmprOrdinaryWageRate] [money] NULL,
	[OrdinaryWageCap] [money] NULL,
	[OrdinaryWageCapInMonths] [int] NULL,
	[EmpAdditionalWageRate] [money] NULL,
	[EmprAdditionalWageRate] [money] NULL,
	[SDLRate] [money] NULL,
	[SDLMin] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[CountryCode] [nvarchar](10) NULL,
	[IsDummyEffectiveTo] [bit] NULL,
	[SDLMax] [money] NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_CPFSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[CPFSettings] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[CPFSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[CPFSettings]  WITH CHECK ADD  CONSTRAINT [FK_CPFSettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[CPFSettings] CHECK CONSTRAINT [FK_CPFSettings_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CapitalAllowance]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CapitalAllowance](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TypeOfClaim] [nvarchar](100) NULL,
	[LifeofYears] [decimal](17, 2) NOT NULL,
	[IntialAllowance] [decimal](18, 0) NULL,
	[EffectiveFromDate] [datetime2](7) NULL,
	[EffectiveToDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[Status] [int] NOT NULL,
	[EffectiveType] [nvarchar](20) NULL,
	[EffectiveFromYA] [int] NULL,
	[EffectiveToYA] [int] NULL,
	[PICQualified] [nvarchar](20) NULL,
 CONSTRAINT [PK_capitalAllowance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Rebates]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Rebates](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RebatesType] [nvarchar](20) NULL,
	[MaximumCapable] [decimal](20, 0) NULL,
	[CorporateIncome] [decimal](15, 2) NULL,
	[EffectiveFromYA] [int] NULL,
	[EffectiveToYA] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_Rebates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Rebates]  WITH CHECK ADD  CONSTRAINT [PK_Rebates_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[Rebates] CHECK CONSTRAINT [PK_Rebates_Company]
GO

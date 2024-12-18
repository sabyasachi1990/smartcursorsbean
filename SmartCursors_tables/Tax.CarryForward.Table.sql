USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[CarryForward]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[CarryForward](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[YearOfAssesment] [int] NULL,
	[BalanceBroughtFwd] [decimal](15, 0) NULL,
	[CYWrittenOff] [decimal](15, 0) NULL,
	[CYClaim] [decimal](15, 0) NULL,
	[CYUtilization] [decimal](15, 0) NULL,
	[BalanceCarryFwd] [decimal](15, 0) NULL,
	[IsQualifyigTest] [bit] NULL,
	[IsQT1Selected] [bit] NULL,
	[IsQT2Selected] [bit] NULL,
	[IsQT3Selected] [bit] NULL,
	[IsCYWrittenOff] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
 CONSTRAINT [PK_CarryForward] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[CarryForward]  WITH CHECK ADD  CONSTRAINT [FK_CarryForward_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[CarryForward] CHECK CONSTRAINT [FK_CarryForward_TaxCompanyEngagement]
GO

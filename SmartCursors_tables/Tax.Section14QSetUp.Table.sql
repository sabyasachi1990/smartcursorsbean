USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Section14QSetUp]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Section14QSetUp](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[OutstandingTaxLife] [int] NULL,
	[NumberOfYA] [int] NULL,
	[TotalAmount] [decimal](15, 0) NULL,
	[EffectiveFromYA] [int] NULL,
	[EffectiveToYA] [int] NULL,
	[EffectiveFromDate] [datetime2](7) NULL,
	[EffectiveToDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Section14QSetUp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Section14QSetUp]  WITH CHECK ADD  CONSTRAINT [PK_Section14QSetUp_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[Section14QSetUp] CHECK CONSTRAINT [PK_Section14QSetUp_Company]
GO

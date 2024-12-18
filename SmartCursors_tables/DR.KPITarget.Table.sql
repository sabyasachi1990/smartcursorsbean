USE [SmartCursorSTG]
GO
/****** Object:  Table [DR].[KPITarget]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DR].[KPITarget](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TargetType] [nvarchar](100) NULL,
	[TargetName] [nvarchar](200) NULL,
	[TargetSymbol] [nvarchar](20) NULL,
	[Target] [decimal](17, 2) NULL,
	[Status] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[FairStartValue] [decimal](10, 2) NULL,
	[FairEndValue] [decimal](10, 2) NULL,
 CONSTRAINT [PK_KPITarget] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [DR].[KPITarget] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [DR].[KPITarget]  WITH CHECK ADD  CONSTRAINT [FK_KPITarget_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [DR].[KPITarget] CHECK CONSTRAINT [FK_KPITarget_Company]
GO

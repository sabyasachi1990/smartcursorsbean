USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[DevelopmentPlan]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[DevelopmentPlan](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DevelopmentPlanMethod] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](1000) NOT NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
 CONSTRAINT [PK_DevelopmentPlan] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[DevelopmentPlan] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[DevelopmentPlan] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[DevelopmentPlan]  WITH CHECK ADD  CONSTRAINT [FK_DevelopmentPlan_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[DevelopmentPlan] CHECK CONSTRAINT [FK_DevelopmentPlan_Company]
GO

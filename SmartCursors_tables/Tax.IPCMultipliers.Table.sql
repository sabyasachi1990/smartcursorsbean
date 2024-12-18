USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[IPCMultipliers]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[IPCMultipliers](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[IPCMultiplierPercentage] [int] NOT NULL,
	[EffectiveFromDate] [datetime2](7) NULL,
	[EffectiveToDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[EffectiveFromYA] [int] NULL,
	[EffectiveToYA] [int] NULL,
 CONSTRAINT [PK_IPCMultipliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[IPCMultipliers] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[IPCMultipliers]  WITH CHECK ADD  CONSTRAINT [Fk_IPCMultipliers_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[IPCMultipliers] CHECK CONSTRAINT [Fk_IPCMultipliers_CompanyId]
GO

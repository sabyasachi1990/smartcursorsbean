USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TickMarkSetup]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TickMarkSetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](300) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TickMarkSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TickMarkSetup] ADD  DEFAULT ((0)) FOR [IsSystem]
GO
ALTER TABLE [Tax].[TickMarkSetup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TickMarkSetup]  WITH CHECK ADD  CONSTRAINT [Fk_TickMarkSetup_CompanyID] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TickMarkSetup] CHECK CONSTRAINT [Fk_TickMarkSetup_CompanyID]
GO

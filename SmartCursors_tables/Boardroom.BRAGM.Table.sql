USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[BRAGM]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[BRAGM](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Section175] [datetime2](7) NULL,
	[ARDate] [datetime2](7) NULL,
	[ARDueDate] [datetime2](7) NULL,
	[LastAGM] [datetime2](7) NULL,
	[AGMDate] [datetime2](7) NULL,
	[ExtSection175 ] [datetime2](7) NULL,
	[Section197] [datetime2](7) NULL,
	[IncorporationDate] [datetime2](7) NOT NULL,
	[FYE] [datetime2](7) NULL,
	[FirstAGM] [nvarchar](10) NOT NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[UserCreated] [nvarchar](250) NULL,
	[IsDisable] [bit] NOT NULL,
	[Status] [int] NOT NULL,
	[Version] [int] NULL,
	[IsFirst] [bit] NULL,
	[ReminderDate] [datetime2](7) NULL,
	[ExtSection197] [datetime2](7) NULL,
	[Day] [nvarchar](20) NULL,
	[Month] [nvarchar](20) NULL,
	[Year] [nvarchar](20) NULL,
 CONSTRAINT [Pk_BRAGM] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[BRAGM]  WITH CHECK ADD  CONSTRAINT [FK_Company_BRAGM] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[BRAGM] CHECK CONSTRAINT [FK_Company_BRAGM]
GO
ALTER TABLE [Boardroom].[BRAGM]  WITH CHECK ADD  CONSTRAINT [FK_EntityDetail_BRAGM] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[BRAGM] CHECK CONSTRAINT [FK_EntityDetail_BRAGM]
GO

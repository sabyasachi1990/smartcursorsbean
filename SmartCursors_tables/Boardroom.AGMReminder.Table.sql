USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMReminder]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMReminder](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[FromDate] [datetime2](7) NULL,
	[ToDate] [datetime2](7) NULL,
	[CurrentFYE] [datetime2](7) NOT NULL,
	[LastAGMDate] [datetime2](7) NULL,
	[Section175] [datetime2](7) NULL,
	[Section197] [datetime2](7) NULL,
	[Section201] [datetime2](7) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[SentOn] [datetime2](7) NULL,
	[SentBY] [nvarchar](50) NOT NULL,
	[ToAddress] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_AGMReminder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMReminder] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[AGMReminder]  WITH CHECK ADD  CONSTRAINT [FK_AGMReminder_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[AGMReminder] CHECK CONSTRAINT [FK_AGMReminder_Company]
GO
ALTER TABLE [Boardroom].[AGMReminder]  WITH CHECK ADD  CONSTRAINT [FK_AGMReminder_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[AGMReminder] CHECK CONSTRAINT [FK_AGMReminder_EntityDetail]
GO

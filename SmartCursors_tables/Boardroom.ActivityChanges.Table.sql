USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[ActivityChanges]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[ActivityChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[CurrentPrimaryActivity] [nvarchar](500) NULL,
	[CurrentPrimaryUserDescribedActivity] [nvarchar](200) NULL,
	[CurrentSecondaryActivity] [nvarchar](200) NULL,
	[CurrentSeondaryUserDescribedActivity] [nvarchar](200) NULL,
	[ProposedPrimaryActivity] [nvarchar](500) NULL,
	[ProposedUserDescribedActivity] [nvarchar](300) NULL,
	[ProposedSecondaryActivity] [nvarchar](500) NULL,
	[ProposedtSeondaryUserDescribedActivity] [nvarchar](300) NULL,
	[EntityActivityId] [uniqueidentifier] NULL,
	[PraposedPSSICCode] [nvarchar](30) NULL,
	[PraposedSSICCode] [nvarchar](30) NULL,
	[IsLocalCompany] [bit] NULL,
	[IsActvityDeleted] [bit] NULL,
	[CurrentPrimarySSICCode] [nvarchar](250) NULL,
	[CurrentSecondarySSICCode] [nvarchar](250) NULL,
 CONSTRAINT [PK_ActivityChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[ActivityChanges]  WITH CHECK ADD  CONSTRAINT [FK_ActivityChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[ActivityChanges] CHECK CONSTRAINT [FK_ActivityChanges_Changes]
GO
ALTER TABLE [Boardroom].[ActivityChanges]  WITH CHECK ADD  CONSTRAINT [FK_ActivityChanges_EntityActivity] FOREIGN KEY([EntityActivityId])
REFERENCES [Boardroom].[EntityActivity] ([Id])
GO
ALTER TABLE [Boardroom].[ActivityChanges] CHECK CONSTRAINT [FK_ActivityChanges_EntityActivity]
GO

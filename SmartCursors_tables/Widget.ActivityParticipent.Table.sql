USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[ActivityParticipent]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[ActivityParticipent](
	[Id] [uniqueidentifier] NOT NULL,
	[ActivityId] [uniqueidentifier] NOT NULL,
	[ParticipentId] [uniqueidentifier] NOT NULL,
	[Username] [nvarchar](254) NULL,
	[Name] [nvarchar](254) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ActivityParticipent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[ActivityParticipent]  WITH CHECK ADD  CONSTRAINT [FK_ActivityParticipent_Activity] FOREIGN KEY([ActivityId])
REFERENCES [Widget].[Activity] ([Id])
GO
ALTER TABLE [Widget].[ActivityParticipent] CHECK CONSTRAINT [FK_ActivityParticipent_Activity]
GO
ALTER TABLE [Widget].[ActivityParticipent]  WITH CHECK ADD  CONSTRAINT [FK_ActivityParticipent_UserAccount] FOREIGN KEY([ParticipentId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Widget].[ActivityParticipent] CHECK CONSTRAINT [FK_ActivityParticipent_UserAccount]
GO

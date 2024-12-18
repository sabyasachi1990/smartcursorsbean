USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AdressesActivity]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AdressesActivity](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[CurrentIsFiveHours] [bit] NOT NULL,
	[CurrentIsThreeHours] [bit] NOT NULL,
	[CurrentNofHours] [nvarchar](20) NULL,
	[PraposedIsFiveHours] [bit] NOT NULL,
	[PraposedIsThreeHours] [bit] NOT NULL,
	[PraposedNofHours] [nvarchar](20) NULL,
	[Status] [int] NOT NULL,
	[IsCurrentNoOfHoursApplicable] [bit] NULL,
 CONSTRAINT [PK_AdressesActivity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AdressesActivity] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[AdressesActivity]  WITH CHECK ADD  CONSTRAINT [FK_Changes_AddressesActivity] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[AdressesActivity] CHECK CONSTRAINT [FK_Changes_AddressesActivity]
GO

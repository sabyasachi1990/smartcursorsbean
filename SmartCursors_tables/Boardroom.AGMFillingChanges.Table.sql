USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMFillingChanges]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMFillingChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[State] [nvarchar](100) NULL,
	[ProposedDateofAGM] [datetime2](7) NULL,
	[CurrentDateofAGM] [datetime2](7) NULL,
	[ProposedDateofAR] [datetime2](7) NULL,
	[CurrentARDate] [datetime2](7) NULL,
	[AGMId] [uniqueidentifier] NULL,
	[IncorporationDate] [datetime2](7) NULL,
	[LastAGMDate] [datetime2](7) NULL,
	[FyeDate] [datetime2](7) NULL,
	[CurrentAGMDueDate] [datetime2](7) NULL,
	[CurrentARDueDate] [datetime2](7) NULL,
 CONSTRAINT [PK_AGMFillingChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMFillingChanges]  WITH CHECK ADD  CONSTRAINT [FK_AGMFillingChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[AGMFillingChanges] CHECK CONSTRAINT [FK_AGMFillingChanges_Changes]
GO

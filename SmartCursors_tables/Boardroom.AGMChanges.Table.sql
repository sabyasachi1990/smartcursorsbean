USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMChanges]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[PeriodofExtensionS175] [nvarchar](100) NULL,
	[ExtendedAGMDateS175] [datetime2](7) NULL,
	[CurrentSection175] [datetime2](7) NULL,
	[CurrentAGMDate] [datetime2](7) NULL,
	[AGMId] [uniqueidentifier] NULL,
	[ReasonforExtension] [nvarchar](max) NULL,
	[TypeOfExtension] [nvarchar](50) NULL,
	[Remarks] [nvarchar](max) NULL,
 CONSTRAINT [PK_AGMChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMChanges]  WITH CHECK ADD  CONSTRAINT [FK_AGMChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[AGMChanges] CHECK CONSTRAINT [FK_AGMChanges_Changes]
GO

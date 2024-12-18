USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[FYEChanges]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[FYEChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[EndDate] [datetime2](7) NULL,
	[CurrentFYE] [nvarchar](40) NULL,
	[ProposedFYE] [nvarchar](40) NULL,
	[AGMDueDateSec175] [datetime2](7) NULL,
 CONSTRAINT [PK_FYEChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[FYEChanges]  WITH CHECK ADD  CONSTRAINT [FK_FYEChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[FYEChanges] CHECK CONSTRAINT [FK_FYEChanges_Changes]
GO
ALTER TABLE [Boardroom].[FYEChanges]  WITH CHECK ADD  CONSTRAINT [FK_FYEChanges_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[FYEChanges] CHECK CONSTRAINT [FK_FYEChanges_EntityDetail]
GO

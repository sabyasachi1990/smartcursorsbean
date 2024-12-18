USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[EntityChanges]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[EntityChanges](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[ProposedEntityName] [nvarchar](100) NOT NULL,
	[ProposedSuffix] [nvarchar](50) NOT NULL,
	[CurrentEntityName] [nvarchar](100) NOT NULL,
	[CurrentEntityType] [nvarchar](100) NOT NULL,
	[IsPricipalApproval] [bit] NOT NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[CurrentFYE] [nvarchar](20) NULL,
	[CurrentCompanyType] [nvarchar](100) NULL,
	[CurrentSuffix] [nvarchar](40) NULL,
	[SuffixId] [bigint] NULL,
 CONSTRAINT [PK_EntityChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[EntityChanges] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[EntityChanges]  WITH CHECK ADD  CONSTRAINT [FK_EntityChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[EntityChanges] CHECK CONSTRAINT [FK_EntityChanges_Changes]
GO

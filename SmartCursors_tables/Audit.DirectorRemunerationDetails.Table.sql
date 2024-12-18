USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[DirectorRemunerationDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[DirectorRemunerationDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[DirectorRemunerationId] [uniqueidentifier] NOT NULL,
	[Heading] [nvarchar](256) NULL,
	[HeadingRecorder] [int] NULL,
	[LineItemName] [nvarchar](256) NULL,
	[LineItemAmount] [decimal](10, 2) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
 CONSTRAINT [PK_DirectorRemunerationDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[DirectorRemunerationDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[DirectorRemunerationDetails]  WITH CHECK ADD  CONSTRAINT [FK_DirectorRemunerationDetails_DirectorRemuneration] FOREIGN KEY([DirectorRemunerationId])
REFERENCES [Audit].[DirectorRemuneration] ([Id])
GO
ALTER TABLE [Audit].[DirectorRemunerationDetails] CHECK CONSTRAINT [FK_DirectorRemunerationDetails_DirectorRemuneration]
GO

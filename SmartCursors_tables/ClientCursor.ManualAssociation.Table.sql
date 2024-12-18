USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[ManualAssociation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[ManualAssociation](
	[Id] [uniqueidentifier] NOT NULL,
	[FromAccountId] [uniqueidentifier] NOT NULL,
	[ToAccountId] [uniqueidentifier] NOT NULL,
	[RelationShip] [nvarchar](100) NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ManualAssociation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[ManualAssociation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[ManualAssociation]  WITH CHECK ADD  CONSTRAINT [FK_ManualAssociation_Account] FOREIGN KEY([FromAccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [ClientCursor].[ManualAssociation] CHECK CONSTRAINT [FK_ManualAssociation_Account]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[EntityActivity]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[EntityActivity](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[PASSICCode] [nvarchar](10) NULL,
	[PrimaryActivity] [nvarchar](500) NULL,
	[PADescription] [varchar](200) NULL,
	[SASSICCode] [nvarchar](5) NULL,
	[SecondaryActivity] [nvarchar](300) NULL,
	[SADescription] [varchar](200) NULL,
	[Type] [nvarchar](100) NULL,
	[IsPricipalApproval] [bit] NOT NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[State] [nvarchar](20) NULL,
	[IsTemporary] [bit] NULL,
 CONSTRAINT [PK_EntityActivity] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[EntityActivity]  WITH CHECK ADD  CONSTRAINT [FK_EntityActivity_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[EntityActivity] CHECK CONSTRAINT [FK_EntityActivity_Company]
GO
ALTER TABLE [Boardroom].[EntityActivity]  WITH CHECK ADD  CONSTRAINT [FK_EntityActivity_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[EntityActivity] CHECK CONSTRAINT [FK_EntityActivity_EntityDetail]
GO

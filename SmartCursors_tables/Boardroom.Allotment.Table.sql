USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Allotment]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Allotment](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Class] [nvarchar](254) NULL,
	[Currency] [nvarchar](254) NULL,
	[ModeofAllotment] [nvarchar](100) NULL,
	[NatureofAllotment] [nvarchar](1000) NULL,
	[NumberofShares] [int] NOT NULL,
	[AmtofIssuedShareCapital] [decimal](18, 2) NOT NULL,
	[AmtofPaidUpShareCapital] [decimal](18, 2) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsChangesAllotment] [bit] NULL,
	[ChangesAllotmentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Allotment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Allotment]  WITH CHECK ADD  CONSTRAINT [FK_Allotment_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Allotment] CHECK CONSTRAINT [FK_Allotment_EntityDetail]
GO

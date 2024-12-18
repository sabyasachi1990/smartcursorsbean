USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[ClaimSetupDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[ClaimSetupDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ClaimSetupId] [uniqueidentifier] NOT NULL,
	[ClaimItemId] [uniqueidentifier] NOT NULL,
	[TransactionLimit] [money] NULL,
	[AnnualLimit] [money] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
 CONSTRAINT [PK_ClaimsSetupDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[ClaimSetupDetail]  WITH CHECK ADD  CONSTRAINT [FK_ClaimsSetupDetails_ClaimItem] FOREIGN KEY([ClaimItemId])
REFERENCES [HR].[ClaimItem] ([Id])
GO
ALTER TABLE [HR].[ClaimSetupDetail] CHECK CONSTRAINT [FK_ClaimsSetupDetails_ClaimItem]
GO
ALTER TABLE [HR].[ClaimSetupDetail]  WITH CHECK ADD  CONSTRAINT [FK_ClaimsSetupDetails_ClaimsSetup] FOREIGN KEY([ClaimSetupId])
REFERENCES [HR].[ClaimSetup] ([Id])
GO
ALTER TABLE [HR].[ClaimSetupDetail] CHECK CONSTRAINT [FK_ClaimsSetupDetails_ClaimsSetup]
GO

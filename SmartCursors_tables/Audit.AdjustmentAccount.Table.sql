USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AdjustmentAccount]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AdjustmentAccount](
	[ID] [uniqueidentifier] NOT NULL,
	[AdjustmentID] [uniqueidentifier] NULL,
	[Account] [uniqueidentifier] NOT NULL,
	[DebitOrCredit] [float] NULL,
	[NetIncomeEffect] [float] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[AccountClass] [nvarchar](25) NULL,
 CONSTRAINT [PK_AdjustmentAccount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AdjustmentAccount] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AdjustmentAccount]  WITH CHECK ADD  CONSTRAINT [FK_AdjustmentAccount_Adjustment] FOREIGN KEY([AdjustmentID])
REFERENCES [Audit].[Adjustment] ([ID])
GO
ALTER TABLE [Audit].[AdjustmentAccount] CHECK CONSTRAINT [FK_AdjustmentAccount_Adjustment]
GO

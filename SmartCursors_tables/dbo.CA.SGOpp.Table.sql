USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[CA.SGOpp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CA.SGOpp](
	[Svc Name] [nvarchar](255) NULL,
	[From] [datetime] NULL,
	[To] [datetime] NULL,
	[Fee] [float] NULL,
	[State] [nvarchar](255) NULL,
	[Svc Ent] [nvarchar](255) NULL,
	[ReOpen] [datetime] NULL,
	[Type] [nvarchar](255) NULL,
	[Opp Ref# No] [nvarchar](255) NULL,
	[Acc/Lead] [nvarchar](255) NULL
) ON [PRIMARY]
GO

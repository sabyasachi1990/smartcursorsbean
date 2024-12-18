USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[FEAnalysis]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[FEAnalysis](
	[ID] [uniqueidentifier] NOT NULL,
	[ForeignExchangeID] [uniqueidentifier] NULL,
	[Source] [nvarchar](50) NULL,
	[Startdate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignExchangeAnalysis] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[FEAnalysis] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[FEAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_ForeignExchangeAnalysis_ForeignExchange] FOREIGN KEY([ForeignExchangeID])
REFERENCES [Tax].[ForeignExchange] ([ID])
GO
ALTER TABLE [Tax].[FEAnalysis] CHECK CONSTRAINT [FK_ForeignExchangeAnalysis_ForeignExchange]
GO

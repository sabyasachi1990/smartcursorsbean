USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[FEAnalysisCurrencyDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[FEAnalysisCurrencyDetails](
	[ID] [uniqueidentifier] NOT NULL,
	[CuntryCurrencyID] [uniqueidentifier] NULL,
	[ClientRate] [money] NULL,
	[Suggested] [decimal](17, 6) NULL,
	[Month] [nvarchar](50) NULL,
	[MonthFirstDate] [datetime] NULL,
	[Difference_Percentage] [money] NULL,
	[NoteID] [uniqueidentifier] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ForeignExchangeAnalysisCurrencyDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[FEAnalysisCurrencyDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[FEAnalysisCurrencyDetails]  WITH CHECK ADD  CONSTRAINT [FK_FEAnalysisCurrencyDetails_FEAnalysisCountryCurrency] FOREIGN KEY([CuntryCurrencyID])
REFERENCES [Audit].[FEAnalysisCountryCurrency] ([ID])
GO
ALTER TABLE [Audit].[FEAnalysisCurrencyDetails] CHECK CONSTRAINT [FK_FEAnalysisCurrencyDetails_FEAnalysisCountryCurrency]
GO

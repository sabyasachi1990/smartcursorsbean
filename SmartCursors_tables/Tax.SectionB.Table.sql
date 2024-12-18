USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[SectionB]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[SectionB](
	[Id] [uniqueidentifier] NOT NULL,
	[SECTIONAId] [uniqueidentifier] NOT NULL,
	[YearOfAccessment] [int] NULL,
	[DeferAnnualAllowance] [bit] NULL,
	[InitialAllowence] [decimal](17, 2) NULL,
	[AnnualAllowance] [decimal](17, 2) NULL,
	[TWDV] [decimal](17, 2) NULL,
	[TWDVBroughtForward] [decimal](17, 2) NULL,
	[DisposalAmount] [decimal](17, 2) NULL,
	[Recorder] [int] NULL,
	[Year] [int] NULL,
	[Amount] [decimal](17, 2) NULL,
	[TotalAnnualAllowance] [decimal](17, 2) NULL,
	[YearsValues] [nvarchar](256) NULL,
	[SpecialAnnualAllowance] [decimal](17, 0) NULL,
	[TempAnnualAllowance] [decimal](17, 0) NULL,
	[Remarks] [nvarchar](256) NULL,
	[TempYearsValues] [nvarchar](256) NULL,
 CONSTRAINT [PK_SECTIONB-COMPUTATIONOFCA] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[SectionB].[DisposalAmount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Tax].[SectionB].[Amount] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Tax].[SectionB]  WITH CHECK ADD  CONSTRAINT [FK_SECTIONB-COMPUTATIONOFCA_SECTIONA] FOREIGN KEY([SECTIONAId])
REFERENCES [Tax].[SectionA] ([Id])
GO
ALTER TABLE [Tax].[SectionB] CHECK CONSTRAINT [FK_SECTIONB-COMPUTATIONOFCA_SECTIONA]
GO

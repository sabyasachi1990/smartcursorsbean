USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraisalAppraiseeWeightage]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraisalAppraiseeWeightage](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalId] [uniqueidentifier] NOT NULL,
	[AppraisalMappingId] [uniqueidentifier] NOT NULL,
	[AppraiseeId] [uniqueidentifier] NOT NULL,
	[AvgRating] [decimal](17, 2) NULL,
	[SelfRating] [decimal](17, 2) NULL,
	[Weightage] [decimal](17, 2) NULL,
	[SelfWeightage] [decimal](17, 2) NULL,
	[TotalResponse] [bigint] NULL,
 CONSTRAINT [PK_AppraisalAppraiseeWeightage] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraisalAppraiseeWeightage]  WITH CHECK ADD  CONSTRAINT [PK_AppraisalAppraiseeWeightage_Appraisal] FOREIGN KEY([AppraisalId])
REFERENCES [HR].[Appraisal] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeWeightage] CHECK CONSTRAINT [PK_AppraisalAppraiseeWeightage_Appraisal]
GO
ALTER TABLE [HR].[AppraisalAppraiseeWeightage]  WITH CHECK ADD  CONSTRAINT [PK_AppraisalAppraiseeWeightage_AppraisalMapping] FOREIGN KEY([AppraisalMappingId])
REFERENCES [HR].[AppraisalMapping] ([Id])
GO
ALTER TABLE [HR].[AppraisalAppraiseeWeightage] CHECK CONSTRAINT [PK_AppraisalAppraiseeWeightage_AppraisalMapping]
GO

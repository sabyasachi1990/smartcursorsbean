USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseLikelihoodHistory]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseLikelihoodHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NULL,
	[Likelihood] [nvarchar](20) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_CaseLikelihoodHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR8SSectionC]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR8SSectionC](
	[Id] [uniqueidentifier] NOT NULL,
	[IR8SId] [uniqueidentifier] NOT NULL,
	[Amount] [money] NULL,
	[FromPeriod] [datetime2](7) NULL,
	[ToPeriod] [datetime2](7) NULL,
	[DatePaid] [datetime2](7) NULL,
	[EmprContribution] [money] NULL,
	[EmprInterest] [money] NULL,
	[EmprRefundDate] [datetime2](7) NULL,
	[EmpContribution] [money] NULL,
	[EmpInterest] [money] NULL,
	[EmpRefundDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[RecOrder] [int] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_IR8SSectionCDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[IR8SSectionC]  WITH CHECK ADD  CONSTRAINT [PK_IR8SSectionCDetails_IR8S] FOREIGN KEY([IR8SId])
REFERENCES [HR].[IR8S] ([Id])
GO
ALTER TABLE [HR].[IR8SSectionC] CHECK CONSTRAINT [PK_IR8SSectionCDetails_IR8S]
GO

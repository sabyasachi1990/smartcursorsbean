USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraiseAppraisers]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraiseAppraisers](
	[Id ] [uniqueidentifier] NOT NULL,
	[AppraisalDetailId] [uniqueidentifier] NOT NULL,
	[AppraiserId] [uniqueidentifier] NOT NULL,
	[IsReplied] [bit] NULL,
	[Recorder] [int] NULL,
	[WeightedAverage] [decimal](30, 2) NULL,
	[AppraiserModifiedBy] [nvarchar](254) NULL,
	[AppraiserModifiedDate] [datetime2](7) NULL,
	[IsSelfAppraiser] [bit] NULL,
	[IsInCharge] [bit] NULL,
	[IsSelected] [bit] NULL,
	[ManageAppraisalStatus] [nvarchar](200) NULL,
 CONSTRAINT [PK_AppraiseeAppraisals] PRIMARY KEY CLUSTERED 
(
	[Id ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraiseAppraisers]  WITH CHECK ADD  CONSTRAINT [FK_AppraiseeAppraisals_AppraiseeDetailId] FOREIGN KEY([AppraisalDetailId])
REFERENCES [HR].[AppraisalAppraiseeDetails] ([Id])
GO
ALTER TABLE [HR].[AppraiseAppraisers] CHECK CONSTRAINT [FK_AppraiseeAppraisals_AppraiseeDetailId]
GO
ALTER TABLE [HR].[AppraiseAppraisers]  WITH CHECK ADD  CONSTRAINT [FK_AppraiseeAppraisals_Employee] FOREIGN KEY([AppraiserId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraiseAppraisers] CHECK CONSTRAINT [FK_AppraiseeAppraisals_Employee]
GO

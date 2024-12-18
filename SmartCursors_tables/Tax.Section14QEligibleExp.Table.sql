USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Section14QEligibleExp]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Section14QEligibleExp](
	[Id] [uniqueidentifier] NOT NULL,
	[Section14QId] [uniqueidentifier] NOT NULL,
	[YearOfAssesment] [int] NULL,
	[AllowableAmount] [decimal](15, 0) NULL,
	[DisAllowableAmount] [decimal](15, 0) NULL,
	[RemainingClaim] [decimal](17, 0) NULL,
 CONSTRAINT [PK_Section14QEligibleExp] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Section14QEligibleExp]  WITH CHECK ADD  CONSTRAINT [FK_Section14QEligibleExp_Section14Q] FOREIGN KEY([Section14QId])
REFERENCES [Tax].[Section14Q] ([Id])
GO
ALTER TABLE [Tax].[Section14QEligibleExp] CHECK CONSTRAINT [FK_Section14QEligibleExp_Section14Q]
GO

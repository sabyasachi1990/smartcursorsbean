USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AppraiserIncharge]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AppraiserIncharge](
	[Id] [uniqueidentifier] NOT NULL,
	[AppraisalDetailId] [uniqueidentifier] NULL,
	[InchargeId] [uniqueidentifier] NULL,
	[IsSelected] [bit] NULL,
 CONSTRAINT [PK_AppraiserIncharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AppraiserIncharge]  WITH CHECK ADD  CONSTRAINT [FK_AppraiserIncharge_AppraisalAppraiseeDetails] FOREIGN KEY([AppraisalDetailId])
REFERENCES [HR].[AppraisalAppraiseeDetails] ([Id])
GO
ALTER TABLE [HR].[AppraiserIncharge] CHECK CONSTRAINT [FK_AppraiserIncharge_AppraisalAppraiseeDetails]
GO
ALTER TABLE [HR].[AppraiserIncharge]  WITH CHECK ADD  CONSTRAINT [FK_AppraiserIncharge_employee] FOREIGN KEY([InchargeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[AppraiserIncharge] CHECK CONSTRAINT [FK_AppraiserIncharge_employee]
GO

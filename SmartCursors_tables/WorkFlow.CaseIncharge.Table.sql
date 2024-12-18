USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[CaseIncharge]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[CaseIncharge](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsCaseIncharge] [bit] NULL,
	[CompanyUserId] [bigint] NULL,
 CONSTRAINT [PK_CaseIncharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[CaseIncharge] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[CaseIncharge]  WITH CHECK ADD FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [WorkFlow].[CaseIncharge]  WITH CHECK ADD  CONSTRAINT [FK_CaseIncharge_Case] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [WorkFlow].[CaseIncharge] CHECK CONSTRAINT [FK_CaseIncharge_Case]
GO

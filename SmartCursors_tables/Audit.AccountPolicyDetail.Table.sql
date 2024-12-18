USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AccountPolicyDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AccountPolicyDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NULL,
	[PolicyName] [nvarchar](4000) NULL,
	[PolicyTemplate] [nvarchar](max) NULL,
	[IsChecked] [bit] NULL,
	[IsSytem] [bit] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[PolicyNameId] [uniqueidentifier] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
 CONSTRAINT [PK_AccountPolicyDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[AccountPolicyDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AccountPolicyDetail]  WITH CHECK ADD  CONSTRAINT [FK_AccountPolicyDetail_AccountPolicy] FOREIGN KEY([MasterId])
REFERENCES [Audit].[AccountPolicy] ([Id])
GO
ALTER TABLE [Audit].[AccountPolicyDetail] CHECK CONSTRAINT [FK_AccountPolicyDetail_AccountPolicy]
GO

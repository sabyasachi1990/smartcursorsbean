USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[AccountPolicyDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[AccountPolicyDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NULL,
	[PolicyName] [nvarchar](4000) NULL,
	[PolicyTemplate] [nvarchar](max) NULL,
	[IsChecked] [bit] NULL,
	[IsSytem] [bit] NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_AccountPolicyDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[AccountPolicyDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[AccountPolicyDetail]  WITH CHECK ADD  CONSTRAINT [FK_AccountPolicyDetail_AccountPolicy] FOREIGN KEY([MasterId])
REFERENCES [Tax].[AccountPolicy] ([Id])
GO
ALTER TABLE [Tax].[AccountPolicyDetail] CHECK CONSTRAINT [FK_AccountPolicyDetail_AccountPolicy]
GO

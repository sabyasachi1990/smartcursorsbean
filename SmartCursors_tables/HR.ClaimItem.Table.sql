USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[ClaimItem]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[ClaimItem](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Category] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[ItemName] [nvarchar](50) NULL,
	[IsVerifier] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[IsCategoryDisable] [bit] NULL,
	[COAId] [bigint] NULL,
	[ApproverNames] [nvarchar](max) NULL,
	[verifierNames] [nvarchar](max) NULL,
	[ReviewerNames] [nvarchar](max) NULL,
	[ApproverIds] [nvarchar](max) NULL,
	[verifierIds] [nvarchar](max) NULL,
	[ReviewerIds] [nvarchar](max) NULL,
	[IsNotRequiredReviewer] [bit] NULL,
	[IsNotRequiredApprover] [bit] NULL,
	[IsNotRequiredVerifier] [bit] NULL,
	[IsAllowClaimCategory] [bit] NULL,
 CONSTRAINT [PK_ClaimItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[ClaimItem]  WITH CHECK ADD  CONSTRAINT [FK_ClaimItem_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[ClaimItem] CHECK CONSTRAINT [FK_ClaimItem_Company]
GO

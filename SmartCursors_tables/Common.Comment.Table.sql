USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Comment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Comment](
	[Id] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](256) NULL,
	[TypeId] [uniqueidentifier] NULL,
	[Description] [nvarchar](1500) NULL,
	[IsReply] [bit] NULL,
	[IsResolved] [bit] NULL,
	[IsReview] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[GroupType] [nvarchar](100) NULL,
	[GroupTypeId] [uniqueidentifier] NULL,
	[PageUrl] [nvarchar](500) NULL,
	[ShortName] [nvarchar](20) NULL,
	[Reference] [nvarchar](256) NULL,
	[IncrementBy] [int] NULL,
	[Heading] [nvarchar](100) NULL,
	[CommentNumber] [int] NULL,
	[AccountClass] [nvarchar](50) NULL,
	[FeatureId] [uniqueidentifier] NULL,
	[UserName] [nvarchar](4000) NULL,
	[IsReviewOriginal] [bit] NULL,
	[ParentId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Comment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CommentTable_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CommentTable_ToBeDeleted](
	[ID] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[AdjustmentComment_ID] [uniqueidentifier] NULL,
	[Review] [bit] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime] NULL,
	[Status] [int] NULL,
	[IsResolve] [bit] NULL,
 CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

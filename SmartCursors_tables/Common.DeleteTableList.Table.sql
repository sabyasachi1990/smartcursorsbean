USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DeleteTableList]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DeleteTableList](
	[SchemaName] [nvarchar](525) NULL,
	[TableName] [nvarchar](525) NULL,
	[RecCount] [nvarchar](525) NULL,
	[Relation] [nvarchar](525) NULL,
	[LastCreatedDate] [nvarchar](525) NULL,
	[LastModifiedDate] [nvarchar](525) NULL,
	[Status] [nvarchar](525) NULL,
	[Remarks] [nvarchar](525) NULL,
	[Team Remarks] [nvarchar](525) NULL,
	[Used Relation] [nvarchar](525) NULL,
	[Verified By] [nvarchar](525) NULL
) ON [PRIMARY]
GO

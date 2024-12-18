USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[DeleteDataHistory]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[DeleteDataHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[ModuleName] [nvarchar](250) NULL,
	[ScreenName] [nvarchar](250) NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[ReferenceNumber] [nvarchar](250) NULL,
	[DeletionTimeRecState] [nvarchar](250) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ReferenceDataObject] [nvarchar](max) NULL,
	[ParentId] [uniqueidentifier] NULL,
	[ParentOppNumber] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

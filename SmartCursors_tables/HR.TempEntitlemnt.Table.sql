USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TempEntitlemnt]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TempEntitlemnt](
	[Id] [uniqueidentifier] NOT NULL,
	[EntitlementId] [uniqueidentifier] NULL,
	[IsTaken] [bit] NULL,
	[Count1] [float] NULL,
 CONSTRAINT [PK_TempEntitlemnt_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

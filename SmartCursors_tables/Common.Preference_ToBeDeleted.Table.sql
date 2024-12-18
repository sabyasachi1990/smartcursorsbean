USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Preference_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Preference_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](254) NULL,
	[Type] [nvarchar](254) NULL,
	[PreferenceData] [nvarchar](max) NULL,
	[Related] [nvarchar](20) NULL,
 CONSTRAINT [PK_Preference] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

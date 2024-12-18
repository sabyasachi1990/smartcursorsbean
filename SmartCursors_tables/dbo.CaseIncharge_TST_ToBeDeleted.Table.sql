USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[CaseIncharge_TST_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CaseIncharge_TST_ToBeDeleted](
	[Date] [nvarchar](19) NULL,
	[ClientNane] [nvarchar](92) NULL,
	[Case_Ref_No] [nvarchar](24) NULL,
	[Incharge] [nvarchar](29) NULL,
	[Incharge2] [nvarchar](19) NULL,
	[Incharge3] [nvarchar](15) NULL,
	[Incharge4] [nvarchar](11) NULL,
	[PrimaryIncharge] [nvarchar](19) NULL,
	[PIC] [nvarchar](15) NULL
) ON [PRIMARY]
GO

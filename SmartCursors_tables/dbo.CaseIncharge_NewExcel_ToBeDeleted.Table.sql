USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[CaseIncharge_NewExcel_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CaseIncharge_NewExcel_ToBeDeleted](
	[Case_Ref_No] [nvarchar](24) NULL,
	[ClientName] [nvarchar](92) NULL,
	[Amended_PIC] [nvarchar](26) NULL,
	[Incharge] [nvarchar](29) NULL,
	[Incharge2] [nvarchar](19) NULL,
	[Incharge3] [nvarchar](15) NULL,
	[Incharge4] [nvarchar](11) NULL,
	[PrimaryIncharge] [nvarchar](19) NULL,
	[PIC] [nvarchar](15) NULL,
	[Employee] [nvarchar](26) NULL,
	[Employee1] [nvarchar](26) NULL,
	[Employee2] [nvarchar](26) NULL,
	[Employee3] [nvarchar](26) NULL,
	[Employee4] [nvarchar](26) NULL,
	[Employee5] [nvarchar](26) NULL,
	[Employee6] [nvarchar](26) NULL,
	[Employee7] [nvarchar](12) NULL,
	[Employee8] [nvarchar](26) NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[CaseId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO

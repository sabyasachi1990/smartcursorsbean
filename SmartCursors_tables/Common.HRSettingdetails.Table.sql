USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[HRSettingdetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[HRSettingdetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[CarryforwardResetDate] [datetime] NULL,
	[IsResetCompleted] [bit] NULL,
	[Recorder] [int] NULL,
	[ClaimsCarryforwardResetDate] [datetime] NULL,
	[IsClaimsDisable] [bit] NULL,
	[IsLeavesDisable] [bit] NULL,
	[IsClaimResetCompleted] [bit] NULL,
 CONSTRAINT [PK_HRSettingdetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[HRSettingdetails]  WITH CHECK ADD  CONSTRAINT [PK_HRSettingdetails_Common.HRSettings] FOREIGN KEY([MasterId])
REFERENCES [Common].[HRSettings] ([Id])
GO
ALTER TABLE [Common].[HRSettingdetails] CHECK CONSTRAINT [PK_HRSettingdetails_Common.HRSettings]
GO

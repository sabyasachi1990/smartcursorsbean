USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[EmployeeRank_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[EmployeeRank_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[Rank] [nvarchar](10) NOT NULL,
	[Category] [nvarchar](2) NOT NULL,
	[RatePerHour] [decimal](18, 0) NOT NULL,
	[Designation] [nvarchar](50) NOT NULL,
	[DefaultCategory] [bit] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_EmployeeRank] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[EmployeeRank_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[EmployeeRank_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeRank_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [ClientCursor].[EmployeeRank_ToBeDeleted] CHECK CONSTRAINT [FK_EmployeeRank_Company]
GO

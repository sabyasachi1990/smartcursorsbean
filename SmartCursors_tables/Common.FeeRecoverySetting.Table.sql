USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[FeeRecoverySetting]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[FeeRecoverySetting](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ProgressMin] [int] NULL,
	[ProgressMax] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreateDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[IsAllowBillTo] [bit] NULL,
	[IsAllowTwentyFourHours] [bit] NULL,
 CONSTRAINT [PK_FeeRecoverySetting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[FeeRecoverySetting] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[FeeRecoverySetting]  WITH CHECK ADD  CONSTRAINT [FK_FeeRecoverySetting_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[FeeRecoverySetting] CHECK CONSTRAINT [FK_FeeRecoverySetting_Company]
GO

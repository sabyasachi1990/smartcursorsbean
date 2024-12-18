USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[LeaveEntitlementAdjustment]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[LeaveEntitlementAdjustment](
	[Id] [uniqueidentifier] NOT NULL,
	[LeaveEntitlementId] [uniqueidentifier] NOT NULL,
	[Adjustment] [decimal](17, 2) NULL,
	[Comment] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Recorder] [int] NULL,
	[IsSystem] [bit] NULL,
	[PayrollId] [uniqueidentifier] NULL,
	[PayrollStatus] [nvarchar](50) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_Adjustment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[LeaveEntitlementAdjustment]  WITH CHECK ADD  CONSTRAINT [PK_Adjustment_LeaveEntitlement] FOREIGN KEY([LeaveEntitlementId])
REFERENCES [HR].[LeaveEntitlement] ([Id])
GO
ALTER TABLE [HR].[LeaveEntitlementAdjustment] CHECK CONSTRAINT [PK_Adjustment_LeaveEntitlement]
GO

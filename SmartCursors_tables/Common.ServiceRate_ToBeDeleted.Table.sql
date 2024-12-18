USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ServiceRate_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ServiceRate_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](100) NULL,
	[ServiceGroupId] [bigint] NOT NULL,
	[ServiceId] [bigint] NULL,
	[ChargeType] [nvarchar](10) NOT NULL,
	[TotalRate] [money] NOT NULL,
	[Currency] [nvarchar](5) NULL,
	[TotalHours] [float] NULL,
	[TargetedRecovery] [float] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ServiceRate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Common].[ServiceRate_ToBeDeleted].[Currency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Common].[ServiceRate_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ServiceRate_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRate_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[ServiceRate_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceRate_Service]
GO
ALTER TABLE [Common].[ServiceRate_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRate_ServiceGroup] FOREIGN KEY([ServiceGroupId])
REFERENCES [Common].[ServiceGroup] ([Id])
GO
ALTER TABLE [Common].[ServiceRate_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceRate_ServiceGroup]
GO

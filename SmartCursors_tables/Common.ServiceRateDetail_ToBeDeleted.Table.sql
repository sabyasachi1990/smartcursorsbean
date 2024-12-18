USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ServiceRateDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ServiceRateDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](100) NULL,
	[ServiceRateId] [uniqueidentifier] NOT NULL,
	[DesignationId] [uniqueidentifier] NOT NULL,
	[Rate] [money] NULL,
	[Currency] [nvarchar](5) NULL,
	[NoOfHours] [float] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ServiceRateDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ServiceRateDetail_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ServiceRateDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRateDetail_Designation] FOREIGN KEY([DesignationId])
REFERENCES [Common].[Designation] ([Id])
GO
ALTER TABLE [Common].[ServiceRateDetail_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceRateDetail_Designation]
GO
ALTER TABLE [Common].[ServiceRateDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRateDetail_ServiceRate] FOREIGN KEY([ServiceRateId])
REFERENCES [Common].[ServiceRate_ToBeDeleted] ([Id])
GO
ALTER TABLE [Common].[ServiceRateDetail_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceRateDetail_ServiceRate]
GO

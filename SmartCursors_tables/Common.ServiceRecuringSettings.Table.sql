USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ServiceRecuringSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ServiceRecuringSettings](
	[Id] [bigint] NOT NULL,
	[ServiceId] [bigint] NOT NULL,
	[Frequency] [nvarchar](100) NOT NULL,
	[FromToDate] [nvarchar](100) NOT NULL,
	[OperatorSymbol] [nvarchar](100) NOT NULL,
	[NoOfDays] [float] NULL,
	[Period] [nvarchar](100) NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ServiceRecuringSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ServiceRecuringSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ServiceRecuringSettings]  WITH CHECK ADD  CONSTRAINT [FK_ServiceRecuringSettings_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[ServiceRecuringSettings] CHECK CONSTRAINT [FK_ServiceRecuringSettings_Service]
GO

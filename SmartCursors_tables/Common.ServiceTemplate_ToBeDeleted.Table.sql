USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ServiceTemplate_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ServiceTemplate_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[ServiceId] [bigint] NOT NULL,
	[TemplateMasterId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ServiceTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ServiceTemplate_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[ServiceTemplate_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceTemplate_Service] FOREIGN KEY([ServiceId])
REFERENCES [Common].[Service] ([Id])
GO
ALTER TABLE [Common].[ServiceTemplate_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceTemplate_Service]
GO
ALTER TABLE [Common].[ServiceTemplate_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_ServiceTemplate_TemplateMaster] FOREIGN KEY([TemplateMasterId])
REFERENCES [Common].[TemplateMaster_ToBeDeleted] ([Id])
GO
ALTER TABLE [Common].[ServiceTemplate_ToBeDeleted] CHECK CONSTRAINT [FK_ServiceTemplate_TemplateMaster]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[ClientStatusChange]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[ClientStatusChange](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ClientId] [uniqueidentifier] NOT NULL,
	[State] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_ClientStatusChange] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[ClientStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_ClientStatusChange_Client] FOREIGN KEY([ClientId])
REFERENCES [WorkFlow].[Client] ([Id])
GO
ALTER TABLE [WorkFlow].[ClientStatusChange] CHECK CONSTRAINT [FK_ClientStatusChange_Client]
GO
ALTER TABLE [WorkFlow].[ClientStatusChange]  WITH CHECK ADD  CONSTRAINT [FK_ClientStatusChange_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[ClientStatusChange] CHECK CONSTRAINT [FK_ClientStatusChange_Company]
GO

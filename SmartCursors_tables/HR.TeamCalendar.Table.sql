USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TeamCalendar]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TeamCalendar](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CompanyUserId] [bigint] NOT NULL,
	[ApplyTo] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](500) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_TeamCalendar] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[TeamCalendar]  WITH CHECK ADD  CONSTRAINT [FK_TeamCalendar_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[TeamCalendar] CHECK CONSTRAINT [FK_TeamCalendar_Company]
GO
ALTER TABLE [HR].[TeamCalendar]  WITH CHECK ADD  CONSTRAINT [FK_TeamCalendar_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [HR].[TeamCalendar] CHECK CONSTRAINT [FK_TeamCalendar_CompanyUser]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BeanReceivablePackageLogs]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BeanReceivablePackageLogs](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[PackageName] [nvarchar](100) NULL,
	[TimeStamp] [datetime2](7) NULL
) ON [PRIMARY]
GO

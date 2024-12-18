USE [SmartCursorSTG]
GO
/****** Object:  UserDefinedTableType [dbo].[SDL]    Script Date: 16-12-2024 9.33.40 PM ******/
CREATE TYPE [dbo].[SDL] AS TABLE(
	[Id] [uniqueidentifier] NULL,
	[TotalWageFrom] [money] NULL,
	[TotalWageTo] [money] NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[SDlRate] [money] NULL,
	[SDLMin] [money] NULL,
	[SDLMax] [money] NULL,
	[Status] [int] NULL
)
GO

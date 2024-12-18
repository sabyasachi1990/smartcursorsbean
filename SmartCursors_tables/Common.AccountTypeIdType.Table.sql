USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AccountTypeIdType]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AccountTypeIdType](
	[Id] [bigint] NOT NULL,
	[AccountTypeId] [bigint] NOT NULL,
	[IdTypeId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_AccountTypeIdType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AccountTypeIdType]  WITH CHECK ADD  CONSTRAINT [FK_AccountTypeIdType_AccountType] FOREIGN KEY([AccountTypeId])
REFERENCES [Common].[AccountType] ([Id])
GO
ALTER TABLE [Common].[AccountTypeIdType] CHECK CONSTRAINT [FK_AccountTypeIdType_AccountType]
GO
ALTER TABLE [Common].[AccountTypeIdType]  WITH CHECK ADD  CONSTRAINT [FK_AccountTypeIdType_IdType] FOREIGN KEY([IdTypeId])
REFERENCES [Common].[IdType] ([Id])
GO
ALTER TABLE [Common].[AccountTypeIdType] CHECK CONSTRAINT [FK_AccountTypeIdType_IdType]
GO

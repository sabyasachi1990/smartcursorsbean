USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[XeroAccountTypeDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[XeroAccountTypeDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[XeroAccountTypeId] [uniqueidentifier] NOT NULL,
	[BeanAccountTypeId] [bigint] NOT NULL,
 CONSTRAINT [PK_XeroTaxCodesDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[XeroAccountTypeDetail]  WITH CHECK ADD  CONSTRAINT [FK_XeroAccountTypeDetail_BeanAccountTypeId] FOREIGN KEY([BeanAccountTypeId])
REFERENCES [Bean].[AccountType] ([Id])
GO
ALTER TABLE [Common].[XeroAccountTypeDetail] CHECK CONSTRAINT [FK_XeroAccountTypeDetail_BeanAccountTypeId]
GO
ALTER TABLE [Common].[XeroAccountTypeDetail]  WITH CHECK ADD  CONSTRAINT [FK_XeroAccountTypeDetail_XeroAccountTypeId] FOREIGN KEY([XeroAccountTypeId])
REFERENCES [Common].[XeroAccountType] ([Id])
GO
ALTER TABLE [Common].[XeroAccountTypeDetail] CHECK CONSTRAINT [FK_XeroAccountTypeDetail_XeroAccountTypeId]
GO

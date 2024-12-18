USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[BankFileDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[BankFileDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BankFileId] [uniqueidentifier] NOT NULL,
	[ReceivingBankCode] [nvarchar](50) NOT NULL,
	[ReceivingAccNum] [nvarchar](200) NOT NULL,
	[ReceivingAccName] [nvarchar](400) NOT NULL,
	[Amount] [money] NOT NULL,
	[PaymentDetails] [nvarchar](300) NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[BankName] [nvarchar](200) NULL,
 CONSTRAINT [PK_BankFileDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[BankFileDetail]  WITH CHECK ADD  CONSTRAINT [PK_BankFileDetail_BankFile] FOREIGN KEY([BankFileId])
REFERENCES [HR].[BankFile] ([Id])
GO
ALTER TABLE [HR].[BankFileDetail] CHECK CONSTRAINT [PK_BankFileDetail_BankFile]
GO
ALTER TABLE [HR].[BankFileDetail]  WITH CHECK ADD  CONSTRAINT [PK_BankFileDetail_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[BankFileDetail] CHECK CONSTRAINT [PK_BankFileDetail_Employee]
GO
ALTER TABLE [HR].[BankFileDetail]  WITH CHECK ADD  CONSTRAINT [PK_BankFileDetail_EmployeeClaim1] FOREIGN KEY([TypeId])
REFERENCES [HR].[EmployeeClaim1] ([Id])
GO
ALTER TABLE [HR].[BankFileDetail] CHECK CONSTRAINT [PK_BankFileDetail_EmployeeClaim1]
GO

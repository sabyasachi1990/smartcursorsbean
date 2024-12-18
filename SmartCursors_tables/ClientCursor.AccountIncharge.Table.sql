USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[AccountIncharge]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[AccountIncharge](
	[Id] [uniqueidentifier] NOT NULL,
	[AccountId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NOT NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ISPrimary] [bit] NULL,
	[Username] [nvarchar](508) NULL,
	[CompanyUserId] [bigint] NULL,
 CONSTRAINT [PK_AccountIncharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[AccountIncharge] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[AccountIncharge]  WITH CHECK ADD  CONSTRAINT [FK_AccountIncharge_Account] FOREIGN KEY([AccountId])
REFERENCES [ClientCursor].[Account] ([Id])
GO
ALTER TABLE [ClientCursor].[AccountIncharge] CHECK CONSTRAINT [FK_AccountIncharge_Account]
GO
ALTER TABLE [ClientCursor].[AccountIncharge]  WITH CHECK ADD  CONSTRAINT [FK_CompanyUser_Id] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [ClientCursor].[AccountIncharge] CHECK CONSTRAINT [FK_CompanyUser_Id]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Department]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Department](
	[Id] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](20) NULL,
	[CompanyId] [bigint] NULL,
	[Name] [nvarchar](100) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[ChargeOfRate] [nvarchar](100) NULL,
	[Currency] [nvarchar](100) NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Department] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Common].[Department] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Department]  WITH CHECK ADD  CONSTRAINT [FK_Department_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Department] CHECK CONSTRAINT [FK_Department_Company]
GO

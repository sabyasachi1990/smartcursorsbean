USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Configuration]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Configuration](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Key] [nvarchar](254) NULL,
	[Value] [nvarchar](254) NULL,
	[Formate] [nvarchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Title] [nvarchar](256) NULL,
	[Value1] [nvarchar](256) NULL,
	[Value2] [nvarchar](256) NULL,
	[IsShow] [bit] NULL,
	[Lookupvalues] [nvarchar](1000) NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[Configuration] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[Configuration]  WITH CHECK ADD  CONSTRAINT [PK_Configuration_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[Configuration] CHECK CONSTRAINT [PK_Configuration_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Suffix]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Suffix](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](4) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](4) NULL,
	[Version] [smallint] NULL,
	[TempSuffixId] [bigint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Suffix] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Suffix]  WITH CHECK ADD  CONSTRAINT [FK_Suffix_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Suffix] CHECK CONSTRAINT [FK_Suffix_Company]
GO

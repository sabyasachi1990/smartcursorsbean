USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[AutoNumberCompany]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[AutoNumberCompany](
	[Id] [uniqueidentifier] NOT NULL,
	[SubsideryCompanyId] [bigint] NOT NULL,
	[AutonumberId] [uniqueidentifier] NULL,
	[GeneratedNumber] [nvarchar](50) NULL,
 CONSTRAINT [PK_AutoNumberCompany] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[AutoNumberCompany]  WITH CHECK ADD  CONSTRAINT [FK_AutoNumberCompany_AutoNumber] FOREIGN KEY([AutonumberId])
REFERENCES [Common].[AutoNumber] ([Id])
GO
ALTER TABLE [Common].[AutoNumberCompany] CHECK CONSTRAINT [FK_AutoNumberCompany_AutoNumber]
GO
ALTER TABLE [Common].[AutoNumberCompany]  WITH CHECK ADD  CONSTRAINT [FK_AutoNumberCompany_Company] FOREIGN KEY([SubsideryCompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[AutoNumberCompany] CHECK CONSTRAINT [FK_AutoNumberCompany_Company]
GO

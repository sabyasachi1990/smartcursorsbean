USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[[Common]].[CompanyReports]]]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[[Common]].[CompanyReports]]](
	[Id] [uniqueidentifier] NOT NULL,
	[ReportWorkSpaceDetailId] [uniqueidentifier] NOT NULL,
	[CompanyId] [nvarchar](4000) NULL,
 CONSTRAINT [PK_CompanyReports] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[[Common]].[CompanyReports]]]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReports_ReportWorkSpaceDetail] FOREIGN KEY([ReportWorkSpaceDetailId])
REFERENCES [Common].[ReportWorkSpaceDetail] ([Id ])
GO
ALTER TABLE [Common].[[Common]].[CompanyReports]]] CHECK CONSTRAINT [FK_CompanyReports_ReportWorkSpaceDetail]
GO

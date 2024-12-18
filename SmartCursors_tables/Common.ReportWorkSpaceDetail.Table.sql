USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[ReportWorkSpaceDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[ReportWorkSpaceDetail](
	[Id ] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[ReportId] [uniqueidentifier] NOT NULL,
	[ReportName] [nvarchar](100) NULL,
	[DataSetId] [uniqueidentifier] NULL,
	[Environment] [nvarchar](50) NULL,
 CONSTRAINT [PK_ReportWorkSpaceDetail] PRIMARY KEY CLUSTERED 
(
	[Id ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[ReportWorkSpaceDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReportWorkSpaceDetail_ReportWorkSpace] FOREIGN KEY([MasterId])
REFERENCES [Common].[ReportWorkSpace] ([Id])
GO
ALTER TABLE [Common].[ReportWorkSpaceDetail] CHECK CONSTRAINT [FK_ReportWorkSpaceDetail_ReportWorkSpace]
GO

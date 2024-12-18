USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[BeanSOAReminderBatchListDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[BeanSOAReminderBatchListDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[DocDate] [datetime2](7) NULL,
	[DocNo] [nvarchar](50) NULL,
	[DocType] [nvarchar](20) NULL,
	[DocBalance] [money] NULL,
	[DocumentTotal] [money] NULL,
	[Currency] [nvarchar](256) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[Remarks] [nvarchar](4000) NULL,
	[Status] [int] NULL,
	[CreditNoteBalance] [money] NULL,
 CONSTRAINT [PK_BeanRSOAReminderBatchListDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[BeanSOAReminderBatchListDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[BeanSOAReminderBatchListDetails]  WITH CHECK ADD  CONSTRAINT [FK_BeanSOAReminderBatchListDetail_SOAReminderBatchList] FOREIGN KEY([MasterId])
REFERENCES [Common].[BeanSOAReminderBatchList] ([Id])
GO
ALTER TABLE [Common].[BeanSOAReminderBatchListDetails] CHECK CONSTRAINT [FK_BeanSOAReminderBatchListDetail_SOAReminderBatchList]
GO

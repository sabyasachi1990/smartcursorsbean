USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[MessageDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MessageDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[ToUsername] [nvarchar](254) NULL,
	[MessageBody] [nvarchar](max) NULL,
 CONSTRAINT [PK_MessageDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[MessageDetail]  WITH CHECK ADD  CONSTRAINT [FK_MessageDetail_MessageMaster] FOREIGN KEY([MasterId])
REFERENCES [Common].[MessageMaster] ([Id])
GO
ALTER TABLE [Common].[MessageDetail] CHECK CONSTRAINT [FK_MessageDetail_MessageMaster]
GO

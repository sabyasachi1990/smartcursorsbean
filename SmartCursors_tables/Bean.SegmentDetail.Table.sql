USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[SegmentDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[SegmentDetail](
	[Id] [bigint] NOT NULL,
	[SegmentMasterId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[ParentId] [bigint] NULL,
	[IsSystem] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_SegmentDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[SegmentDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[SegmentDetail]  WITH CHECK ADD  CONSTRAINT [FK_SegmentDetail_SegmentMaster] FOREIGN KEY([SegmentMasterId])
REFERENCES [Bean].[SegmentMaster] ([Id])
GO
ALTER TABLE [Bean].[SegmentDetail] CHECK CONSTRAINT [FK_SegmentDetail_SegmentMaster]
GO

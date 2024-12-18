USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[PricipalApprovalDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[PricipalApprovalDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityActivityId] [uniqueidentifier] NOT NULL,
	[NameOfApprovalAuthority] [nvarchar](500) NOT NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[EntityId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PricipalApprovalDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[PricipalApprovalDetail] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [Boardroom].[PricipalApprovalDetail]  WITH CHECK ADD  CONSTRAINT [FK_PricipalApprovalDetail_EntityActivity] FOREIGN KEY([EntityActivityId])
REFERENCES [Boardroom].[EntityActivity] ([Id])
GO
ALTER TABLE [Boardroom].[PricipalApprovalDetail] CHECK CONSTRAINT [FK_PricipalApprovalDetail_EntityActivity]
GO
ALTER TABLE [Boardroom].[PricipalApprovalDetail]  WITH CHECK ADD  CONSTRAINT [FK_PricipalApprovalDetail_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[PricipalApprovalDetail] CHECK CONSTRAINT [FK_PricipalApprovalDetail_EntityDetail]
GO

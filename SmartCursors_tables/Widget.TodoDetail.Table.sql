USE [SmartCursorSTG]
GO
/****** Object:  Table [Widget].[TodoDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Widget].[TodoDetail](
	[Id] [bigint] NOT NULL,
	[MasterId] [bigint] NOT NULL,
	[Item] [nvarchar](200) NOT NULL,
	[ToDoStatus] [int] NOT NULL,
	[IsSystemGen] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](128) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](128) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TodoDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Widget].[TodoDetail] ADD  DEFAULT ((0)) FOR [IsSystemGen]
GO
ALTER TABLE [Widget].[TodoDetail] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Widget].[TodoDetail]  WITH CHECK ADD  CONSTRAINT [FK_TodoDetail_TodoMaster] FOREIGN KEY([MasterId])
REFERENCES [Widget].[TodoMaster] ([Id])
GO
ALTER TABLE [Widget].[TodoDetail] CHECK CONSTRAINT [FK_TodoDetail_TodoMaster]
GO

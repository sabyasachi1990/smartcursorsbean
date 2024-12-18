USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[SubClass]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[SubClass](
	[Id] [uniqueidentifier] NOT NULL,
	[SharesId] [uniqueidentifier] NOT NULL,
	[SubClassOfShare] [nvarchar](254) NULL,
	[Ordinory] [decimal](10, 2) NULL,
	[Preference] [decimal](10, 2) NULL,
	[Others] [decimal](10, 2) NULL,
	[Description] [nvarchar](500) NULL,
	[Remarks] [nvarchar](500) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_SubClass] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[SubClass] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[SubClass] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[SubClass]  WITH CHECK ADD  CONSTRAINT [FK_SubClass_Shares] FOREIGN KEY([SharesId])
REFERENCES [Boardroom].[Shares] ([Id])
GO
ALTER TABLE [Boardroom].[SubClass] CHECK CONSTRAINT [FK_SubClass_Shares]
GO

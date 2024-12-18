USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Changes]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Changes](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Changein] [nvarchar](100) NOT NULL,
	[FallowUp] [datetime2](7) NULL,
	[EffectiveDateOfChange] [datetime2](7) NULL,
	[DocStatus] [nvarchar](100) NULL,
	[IsCompleted] [bit] NULL,
	[ChangeRefNo] [nvarchar](100) NULL,
	[CompanyId] [bigint] NULL,
	[UserCreated] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[NextFinancialYearEnd] [datetime2](7) NULL,
	[Status] [int] NULL,
	[State] [nvarchar](50) NULL,
	[IsTemporary] [bit] NULL,
	[Remarks] [nvarchar](1000) NULL,
	[RedirectUrl] [nvarchar](max) NULL,
	[IsCopyLink] [bit] NULL,
	[RedirectUrlParams] [nvarchar](max) NULL,
	[ChangesGroup] [nvarchar](300) NULL,
 CONSTRAINT [PK_Changes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Changes] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[Changes]  WITH CHECK ADD  CONSTRAINT [FK_Changes_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Changes] CHECK CONSTRAINT [FK_Changes_Company]
GO
ALTER TABLE [Boardroom].[Changes]  WITH CHECK ADD  CONSTRAINT [FK_Changes_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Changes] CHECK CONSTRAINT [FK_Changes_EntityDetail]
GO

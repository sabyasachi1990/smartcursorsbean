USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[Contacts]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[Contacts](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[GenericContactId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[Remarks] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[IsEntity] [bit] NULL,
	[DateOfCessation] [datetime2](7) NULL,
	[Docstatus] [varchar](50) NULL,
	[IsPrimary] [bit] NULL,
	[IsCessation] [bit] NULL,
	[ReasonForCessation] [nvarchar](max) NULL,
	[DisqualifiedReasons] [nvarchar](max) NULL,
	[DisqualifiedReasonsSubsection] [nvarchar](max) NULL,
	[State] [nvarchar](20) NULL,
	[IsTemporary] [bit] NULL,
	[IsReminder] [bit] NULL,
	[FilePath] [nvarchar](2000) NULL,
 CONSTRAINT [PK_Contacts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[Contacts] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[Contacts] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[Contacts] CHECK CONSTRAINT [FK_Contacts_Company]
GO
ALTER TABLE [Boardroom].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[Contacts] CHECK CONSTRAINT [FK_Contacts_EntityDetail]
GO
ALTER TABLE [Boardroom].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_GenericContact] FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[Contacts] CHECK CONSTRAINT [FK_Contacts_GenericContact]
GO

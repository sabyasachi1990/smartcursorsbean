USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[GenericContactDesignation]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[GenericContactDesignation](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[GenericContactId] [uniqueidentifier] NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](100) NULL,
	[Position] [nvarchar](100) NOT NULL,
	[DateofAppointment] [datetime2](7) NULL,
	[DateofCessation] [datetime2](7) NULL,
	[ReasonforCessation] [nvarchar](100) NULL,
	[DisqualifiedReasons] [nvarchar](200) NULL,
	[DisqualifiedReasonsSubsection] [nvarchar](300) NULL,
	[Remarks] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ShortCode] [nvarchar](50) NOT NULL,
	[CommencementDate] [datetime2](7) NULL,
	[CorporateRepresentative] [nvarchar](100) NULL,
	[AlternateFor] [nvarchar](254) NULL,
	[NominatedBy] [nvarchar](max) NULL,
	[IsRegistrableController] [bit] NULL,
	[IsSignificantInterest] [bit] NULL,
	[IsSignificantControl] [bit] NULL,
	[Sort] [nvarchar](50) NULL,
	[Reason] [nvarchar](max) NULL,
	[RegistrabledBy] [nvarchar](max) NULL,
	[DateofNominator] [datetime2](7) NULL,
	[DateofRegistrable] [datetime2](7) NULL,
	[DateofEntry] [datetime2](7) NULL,
	[RegistrableControllerInfo] [nvarchar](4000) NULL,
 CONSTRAINT [PK_[GenericContactDesignation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation]  WITH CHECK ADD  CONSTRAINT [FK_GenericContactDesignation_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] CHECK CONSTRAINT [FK_GenericContactDesignation_Company]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation]  WITH CHECK ADD  CONSTRAINT [FK_GenericContactDesignation_Contacts] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[Contacts] ([Id])
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] CHECK CONSTRAINT [FK_GenericContactDesignation_Contacts]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation]  WITH CHECK ADD  CONSTRAINT [FK_GenericContactDesignation_EntityDetail] FOREIGN KEY([EntityId])
REFERENCES [Common].[EntityDetail] ([Id])
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] CHECK CONSTRAINT [FK_GenericContactDesignation_EntityDetail]
GO
ALTER TABLE [Boardroom].[GenericContactDesignation]  WITH CHECK ADD  CONSTRAINT [FK_GenericContactDesignation_GenericContact] FOREIGN KEY([GenericContactId])
REFERENCES [Boardroom].[GenericContact] ([Id])
GO
ALTER TABLE [Boardroom].[GenericContactDesignation] CHECK CONSTRAINT [FK_GenericContactDesignation_GenericContact]
GO

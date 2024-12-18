USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[ChangesAppointmentDetails]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[ChangesAppointmentDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[ContactId] [uniqueidentifier] NOT NULL,
	[GCDesignationId] [uniqueidentifier] NULL,
	[OfficerChangesId] [uniqueidentifier] NOT NULL,
	[Position] [nvarchar](250) NOT NULL,
	[DateofAppointment] [datetime2](7) NULL,
	[DateofCessation] [datetime2](7) NULL,
	[ReasonforCessation] [nvarchar](250) NULL,
	[DisqualifiedReasons] [nvarchar](250) NULL,
	[DisqualifiedReasonsSubsection] [nvarchar](250) NULL,
	[Remarks] [nvarchar](250) NULL,
	[UserCreated] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](250) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [int] NULL,
	[Status] [int] NOT NULL,
	[ShortCode] [nvarchar](20) NULL,
	[CommencementDate] [datetime2](7) NULL,
	[AlternateFor] [nvarchar](250) NULL,
	[NominatedBy] [nvarchar](250) NULL,
	[Sort] [nvarchar](150) NULL,
	[Reason] [nvarchar](250) NULL,
	[DateofNominator] [datetime2](7) NULL,
	[DateofEntry] [datetime2](7) NULL,
	[GenericContactId] [uniqueidentifier] NULL,
	[DateofRegistrable] [datetime2](7) NULL,
	[RegistrableControllerInfo] [nvarchar](250) NULL,
	[IsSignificantControl] [bit] NULL,
	[IsSignificantInterest] [bit] NULL,
	[IsRegistrableController] [bit] NULL,
 CONSTRAINT [ChngsAppntmntDetils_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[ChangesAppointmentDetails]  WITH CHECK ADD  CONSTRAINT [ChngsAppntmntDetils_Contact_Id] FOREIGN KEY([ContactId])
REFERENCES [Boardroom].[Contacts] ([Id])
GO
ALTER TABLE [Boardroom].[ChangesAppointmentDetails] CHECK CONSTRAINT [ChngsAppntmntDetils_Contact_Id]
GO
ALTER TABLE [Boardroom].[ChangesAppointmentDetails]  WITH CHECK ADD  CONSTRAINT [ChngsAppntmntDetils_Officer_Id] FOREIGN KEY([OfficerChangesId])
REFERENCES [Boardroom].[OfficerChanges] ([Id])
GO
ALTER TABLE [Boardroom].[ChangesAppointmentDetails] CHECK CONSTRAINT [ChngsAppntmntDetils_Officer_Id]
GO

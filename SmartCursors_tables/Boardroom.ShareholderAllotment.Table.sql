USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[ShareholderAllotment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[ShareholderAllotment](
	[Id] [uniqueidentifier] NOT NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[IsSubClass] [bit] NULL,
	[Class] [nvarchar](50) NULL,
	[IsOrdinory] [bit] NULL,
	[IsPreference] [bit] NULL,
	[IsOthers] [bit] NULL,
	[Ordinory] [nvarchar](100) NULL,
	[Preference] [nvarchar](100) NULL,
	[Others] [nvarchar](100) NULL,
	[IsSharesHeld] [bit] NULL,
	[NameOfTheTrust] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Remarks] [nvarchar](500) NULL,
	[Description] [nvarchar](500) NULL,
	[Type] [nvarchar](100) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_ShareholderAllotment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[ShareholderAllotment] ADD  DEFAULT ((0)) FOR [IsSubClass]
GO
ALTER TABLE [Boardroom].[ShareholderAllotment] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [Boardroom].[ShareholderAllotment] ADD  DEFAULT ((1)) FOR [Status]
GO

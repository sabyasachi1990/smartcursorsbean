USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[AutoNumber]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[AutoNumber](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleMasterId] [bigint] NULL,
	[EntityType] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[Format] [nvarchar](100) NULL,
	[GeneratedNumber] [nvarchar](50) NULL,
	[CounterLength] [int] NULL,
	[MaxLength] [int] NULL,
	[StartNumber] [bigint] NULL,
	[Reset] [nvarchar](20) NULL,
	[Preview] [nvarchar](50) NULL,
	[IsResetbySubsidary] [bit] NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Variables] [nvarchar](256) NULL,
	[Sufix] [nvarchar](20) NULL,
	[Prefix] [nvarchar](20) NULL,
	[Entity] [nvarchar](100) NULL,
	[IsFormatChange] [bit] NULL,
	[IsDisable] [bit] NULL,
	[IsEditable] [bit] NULL,
	[IsEditableDisable] [bit] NULL,
	[EntityId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AutoNumber] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[AutoNumber] ADD  DEFAULT ((1)) FOR [Status]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AppointmentDirector]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AppointmentDirector](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityId] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Salutation] [nvarchar](15) NULL,
	[IDNumber] [nvarchar](250) NOT NULL,
	[IDType] [nvarchar](150) NOT NULL,
	[Nationality] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](20) NULL,
	[Email] [nvarchar](max) NULL,
	[CommencementDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](max) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_AppointmentDirector] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

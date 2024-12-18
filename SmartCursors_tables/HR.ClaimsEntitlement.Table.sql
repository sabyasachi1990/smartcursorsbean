USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[ClaimsEntitlement]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[ClaimsEntitlement](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[ClaimsVerifiers] [nvarchar](1000) NULL,
	[IsNotRequiredVerifier] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[BenefitsCreatedDate] [datetime2](7) NULL,
	[BenefitsModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_ClaimsEntitlement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[ClaimsEntitlement]  WITH CHECK ADD  CONSTRAINT [FK_ClaimsEntitlement_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[ClaimsEntitlement] CHECK CONSTRAINT [FK_ClaimsEntitlement_Employee]
GO

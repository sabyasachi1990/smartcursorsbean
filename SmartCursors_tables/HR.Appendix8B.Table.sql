USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appendix8B]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appendix8B](
	[Id] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[IR8AHRSetUpId] [uniqueidentifier] NOT NULL,
	[CompanyRegistrationNo] [nvarchar](500) NULL,
	[EmployerName] [nvarchar](500) NULL,
	[DateOfIncorporation] [datetime2](7) NULL,
	[AuthorisedPersonMakingDeclaration] [nvarchar](500) NULL,
	[Signature] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[TelNO] [nvarchar](500) NULL,
	[Date] [datetime2](7) NULL,
	[UserCreated] [nvarchar](500) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](500) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_Appendix8B] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Appendix8B]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8B_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Appendix8B] CHECK CONSTRAINT [FK_Appendix8B_Employee]
GO
ALTER TABLE [HR].[Appendix8B]  WITH CHECK ADD  CONSTRAINT [FK_Appendix8B_IR8AHRSetUp] FOREIGN KEY([IR8AHRSetUpId])
REFERENCES [HR].[IR8AHRSetUp] ([Id])
GO
ALTER TABLE [HR].[Appendix8B] CHECK CONSTRAINT [FK_Appendix8B_IR8AHRSetUp]
GO

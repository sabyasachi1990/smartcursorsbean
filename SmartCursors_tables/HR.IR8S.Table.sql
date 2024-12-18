USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[IR8S]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[IR8S](
	[Id] [uniqueidentifier] NOT NULL,
	[IR8AHRSetUpId] [uniqueidentifier] NOT NULL,
	[EmployeeId] [uniqueidentifier] NOT NULL,
	[DateOfRenunciation] [datetime2](7) NULL,
	[DateOfSPRGrantedStatus] [nvarchar](50) NULL,
	[SectionASPRStatus] [nvarchar](50) NULL,
	[SectionBEmpCPF] [money] NULL,
	[SectionBEmprCPF] [money] NULL,
	[SectionCRemarks] [nvarchar](512) NULL,
	[Designation] [nvarchar](100) NULL,
	[EmployerName] [nvarchar](100) NULL,
	[Signature] [nvarchar](100) NULL,
	[Date] [datetime2](7) NULL,
	[TelphoneNum] [nvarchar](50) NULL,
	[AuthorizedPersonName] [nvarchar](100) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[DateOfOverseasPosting] [datetime2](7) NULL,
	[StatusCode] [nvarchar](20) NULL,
	[GeneratedOn] [datetime] NULL,
	[StatusRemarks] [nvarchar](max) NULL,
 CONSTRAINT [PK_IR8S] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[IR8S]  WITH CHECK ADD  CONSTRAINT [PK_IR8S_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[IR8S] CHECK CONSTRAINT [PK_IR8S_Employee]
GO
ALTER TABLE [HR].[IR8S]  WITH CHECK ADD  CONSTRAINT [PK_IR8S_IR8AHRSetUp] FOREIGN KEY([IR8AHRSetUpId])
REFERENCES [HR].[IR8AHRSetUp] ([Id])
GO
ALTER TABLE [HR].[IR8S] CHECK CONSTRAINT [PK_IR8S_IR8AHRSetUp]
GO

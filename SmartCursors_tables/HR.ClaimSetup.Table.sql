USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[ClaimSetup]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[ClaimSetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Category] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NOT NULL,
	[ApplyTo] [nvarchar](50) NOT NULL,
	[DepartmentId] [uniqueidentifier] NULL,
	[DesignationId] [uniqueidentifier] NULL,
	[CategoryLimit] [money] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[IsFromClaimItem] [bit] NOT NULL,
	[IsCategoryDisable] [bit] NULL,
 CONSTRAINT [PK_ClaimsSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[ClaimSetup] ADD  DEFAULT ((1)) FOR [IsFromClaimItem]
GO
ALTER TABLE [HR].[ClaimSetup]  WITH CHECK ADD  CONSTRAINT [FK_ClaimsSetup_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[ClaimSetup] CHECK CONSTRAINT [FK_ClaimsSetup_Company]
GO

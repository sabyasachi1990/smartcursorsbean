USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Questionnaire]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Questionnaire](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Designation] [nvarchar](100) NULL,
	[Level] [nvarchar](4) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[IsLocked] [bit] NULL,
	[DepartmentId] [nvarchar](4000) NULL,
	[DesignationId] [nvarchar](4000) NULL,
	[AppraisalCycle] [nvarchar](100) NULL,
	[AppraiserDepartmentIds] [nvarchar](max) NULL,
	[AppraiserDesignationIds] [nvarchar](max) NULL,
	[CaseMembersOnly] [bit] NULL,
	[LimitNumberOfAppraisers] [nvarchar](100) NULL,
	[NotApplicableWeightage] [bit] NULL,
 CONSTRAINT [PK_Questionnaire] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Questionnaire] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[Questionnaire] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Questionnaire]  WITH CHECK ADD  CONSTRAINT [FK_Questionnaire_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Questionnaire] CHECK CONSTRAINT [FK_Questionnaire_Company]
GO

USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Appraisal]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Appraisal](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[QuestionnaireId] [uniqueidentifier] NOT NULL,
	[AppraiseId] [uniqueidentifier] NULL,
	[Name] [nvarchar](4000) NULL,
	[AppraiserList] [nvarchar](25) NULL,
	[CompletedBy] [datetime2](7) NULL,
	[ApprisalStatus] [nvarchar](25) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [varchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[DesignationName] [nvarchar](30) NULL,
	[AppraisalCycle] [nvarchar](50) NULL,
	[AsAppraisalModifiedBy] [nvarchar](254) NULL,
	[AsAppraisalModifiedDate] [datetime2](7) NULL,
	[SendAppraisalModifiedBy] [nvarchar](254) NULL,
	[SendAppraisalModifiedDate] [datetime2](7) NULL,
	[AppraisalName] [nvarchar](100) NULL,
	[QuestionnaireName] [nvarchar](100) NULL,
	[AppraisersCount] [int] NULL,
	[AppraiseesCount] [int] NULL,
	[GrouppedBy] [nvarchar](20) NULL,
	[IsSelfAppraisal] [bit] NULL,
	[IsHideAppraiserName] [bit] NULL,
	[AssesmentStartDate] [datetime2](7) NULL,
	[AssesmentEndDate] [datetime2](7) NULL,
	[IsShowAtManageAppraisal] [bit] NULL,
	[IsTemp] [bit] NULL,
	[AppraiserDepartmentIds] [nvarchar](max) NULL,
	[AppraiserDesignationIds] [nvarchar](max) NULL,
	[CaseMembersOnly] [bit] NULL,
	[LimitNumberOfAppraisers] [nvarchar](100) NULL,
	[WeightageWithRating] [bit] NULL,
	[WeightageWithOutRating] [bit] NULL,
	[Comments] [bit] NULL,
	[Discussion] [bit] NULL,
	[ManageAppraisalStatus] [nvarchar](200) NULL,
 CONSTRAINT [PK_Appraisal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Appraisal]  WITH CHECK ADD  CONSTRAINT [FK_Appraisal_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Appraisal] CHECK CONSTRAINT [FK_Appraisal_Company]
GO
ALTER TABLE [HR].[Appraisal]  WITH CHECK ADD  CONSTRAINT [FK_Appraisal_Employee] FOREIGN KEY([AppraiseId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Appraisal] CHECK CONSTRAINT [FK_Appraisal_Employee]
GO

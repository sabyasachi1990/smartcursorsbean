USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Payroll]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Payroll](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ParentId] [uniqueidentifier] NULL,
	[Year] [int] NULL,
	[Month] [nvarchar](15) NULL,
	[GeneratedFor] [nvarchar](15) NULL,
	[TotalEmployeesCount] [int] NOT NULL,
	[RemainingEmployeesCount] [int] NULL,
	[PayrollStatus] [nvarchar](15) NULL,
	[IsLock] [bit] NULL,
	[ApprovedBy] [nvarchar](254) NULL,
	[ApprovedDate] [datetime2](7) NULL,
	[RejectedReason] [nvarchar](256) NULL,
	[IsTemporary] [bit] NULL,
	[IsManualCancel] [bit] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreateDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[ProcessedBy] [nvarchar](100) NULL,
	[ProcessedDate] [datetime2](7) NULL,
	[DocumentId] [nvarchar](1000) NULL,
	[SyncPayBillId] [nvarchar](1000) NULL,
	[SyncPayBillStatus] [nvarchar](100) NULL,
	[SyncPayBillDate] [datetime2](7) NULL,
	[SyncPayBillRemarks] [nvarchar](max) NULL,
	[IsCPFGenerated] [bit] NULL,
	[IsBankGenerated] [bit] NULL,
	[AdviceCode] [int] NULL,
	[BatchId] [bigint] NULL,
	[OCBCValueDate] [datetime2](7) NULL,
	[XeroBillIds] [nvarchar](2000) NULL,
	[BeanPostingDate] [datetime2](7) NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [HR].[Payroll]  WITH CHECK ADD  CONSTRAINT [FK_Payroll_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Payroll] CHECK CONSTRAINT [FK_Payroll_Company]
GO

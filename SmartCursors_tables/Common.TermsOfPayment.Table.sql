USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[TermsOfPayment]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[TermsOfPayment](
	[Id] [bigint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[TermsType] [nvarchar](20) NULL,
	[TOPValue] [float] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsVendor] [bit] NULL,
	[IsCustomer] [bit] NULL,
	[IsDefault] [bit] NULL,
 CONSTRAINT [PK_TermsOfPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[TermsOfPayment] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[TermsOfPayment]  WITH CHECK ADD  CONSTRAINT [FK_TermsOfPayment_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[TermsOfPayment] CHECK CONSTRAINT [FK_TermsOfPayment_Company]
GO

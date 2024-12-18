USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Trainer]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Trainer](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EmployeeId] [uniqueidentifier] NULL,
	[TrainerProfile] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
	[Version] [smallint] NULL,
	[CompanyUserId] [bigint] NULL,
	[IsExternalTrainer] [bit] NULL,
	[TrainerName] [nvarchar](200) NULL,
 CONSTRAINT [PK_Trainer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Trainer]  WITH CHECK ADD  CONSTRAINT [FK_Trainer_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Trainer] CHECK CONSTRAINT [FK_Trainer_Company]
GO
ALTER TABLE [HR].[Trainer]  WITH CHECK ADD  CONSTRAINT [FK_Trainer_CompanyUser] FOREIGN KEY([CompanyUserId])
REFERENCES [Common].[CompanyUser] ([Id])
GO
ALTER TABLE [HR].[Trainer] CHECK CONSTRAINT [FK_Trainer_CompanyUser]
GO
ALTER TABLE [HR].[Trainer]  WITH CHECK ADD  CONSTRAINT [FK_Trainer_Employee] FOREIGN KEY([EmployeeId])
REFERENCES [Common].[Employee] ([Id])
GO
ALTER TABLE [HR].[Trainer] CHECK CONSTRAINT [FK_Trainer_Employee]
GO

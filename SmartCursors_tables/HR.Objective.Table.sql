USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[Objective]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Objective](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Type] [nvarchar](30) NOT NULL,
	[Progress] [float] NULL,
	[Weight] [nvarchar](20) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Remarks] [nvarchar](500) NULL,
	[ObjectiveDescription] [nvarchar](500) NULL,
 CONSTRAINT [PK_Objective] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [HR].[Objective] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [HR].[Objective] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [HR].[Objective]  WITH CHECK ADD  CONSTRAINT [FK_Objective_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [HR].[Objective] CHECK CONSTRAINT [FK_Objective_Company]
GO

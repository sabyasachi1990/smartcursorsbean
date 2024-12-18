USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[MessageMaster]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MessageMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](20) NULL,
	[Subject] [nvarchar](1000) NULL,
	[Priority] [bit] NULL,
	[MessageBody] [nvarchar](max) NULL,
	[FromUsername] [nvarchar](254) NULL,
 CONSTRAINT [PK_MessageMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Common].[MessageMaster].[FromUsername] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Credentials', information_type_id = 'c64aba7b-3a3e-95b6-535d-3bc535da5a59', rank = Medium);
GO
ALTER TABLE [Common].[MessageMaster]  WITH CHECK ADD  CONSTRAINT [Fk_MessageMaster_CompanyId] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[MessageMaster] CHECK CONSTRAINT [Fk_MessageMaster_CompanyId]
GO

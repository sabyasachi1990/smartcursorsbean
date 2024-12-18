USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[InCharge]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[InCharge](
	[Id] [uniqueidentifier] NOT NULL,
	[ChangesId] [uniqueidentifier] NULL,
	[UserAccountId] [uniqueidentifier] NOT NULL,
	[DynamicTemplateId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_InChanges] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[InCharge]  WITH CHECK ADD FOREIGN KEY([DynamicTemplateId])
REFERENCES [Boardroom].[DynamicTemplates] ([Id])
GO
ALTER TABLE [Boardroom].[InCharge]  WITH CHECK ADD  CONSTRAINT [FK_InChanges_Changes] FOREIGN KEY([ChangesId])
REFERENCES [Boardroom].[Changes] ([Id])
GO
ALTER TABLE [Boardroom].[InCharge] CHECK CONSTRAINT [FK_InChanges_Changes]
GO
ALTER TABLE [Boardroom].[InCharge]  WITH CHECK ADD  CONSTRAINT [FK_InChanges_UserAccount] FOREIGN KEY([UserAccountId])
REFERENCES [Auth].[UserAccount] ([Id])
GO
ALTER TABLE [Boardroom].[InCharge] CHECK CONSTRAINT [FK_InChanges_UserAccount]
GO

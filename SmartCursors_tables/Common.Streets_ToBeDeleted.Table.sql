USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[Streets_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Streets_ToBeDeleted](
	[StreetKey] [varchar](7) NULL,
	[StreetName] [varchar](32) NULL,
	[Filler] [varchar](6) NULL,
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_Streets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Common].[Streets_ToBeDeleted].[StreetKey] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO
ADD SENSITIVITY CLASSIFICATION TO [Common].[Streets_ToBeDeleted].[StreetName] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Contact Info', information_type_id = '5c503e21-22c6-81fa-620b-f369b8ec38d1', rank = Medium);
GO

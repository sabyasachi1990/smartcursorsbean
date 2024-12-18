USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[HrAuditTrails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[HrAuditTrails](
	[Id] [uniqueidentifier] NOT NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[Type] [nvarchar](50) NULL,
	[TabStatus] [nvarchar](20) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[RecordStatus] [nvarchar](100) NULL,
	[Remarks] [nvarchar](256) NULL,
	[Username] [nvarchar](200) NULL,
	[FileName] [nvarchar](4000) NULL,
	[Reason] [nvarchar](200) NULL,
 CONSTRAINT [PK_HrAuditTrails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

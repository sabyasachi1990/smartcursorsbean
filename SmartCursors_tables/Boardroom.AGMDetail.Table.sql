USE [SmartCursorSTG]
GO
/****** Object:  Table [Boardroom].[AGMDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Boardroom].[AGMDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[AGMId] [uniqueidentifier] NOT NULL,
	[Section] [nvarchar](200) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Duration] [nvarchar](200) NULL,
	[Period] [nvarchar](50) NULL,
	[CalculationBasedOn] [nvarchar](100) NULL,
	[DaysOrMonths] [int] NULL,
	[Type] [nvarchar](200) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
 CONSTRAINT [Pk_AGMDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Boardroom].[AGMDetail]  WITH CHECK ADD  CONSTRAINT [FK_AGM_AGMDetail] FOREIGN KEY([AGMId])
REFERENCES [Boardroom].[AGM] ([Id])
GO
ALTER TABLE [Boardroom].[AGMDetail] CHECK CONSTRAINT [FK_AGM_AGMDetail]
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Autonumber_Year_Update]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [SP_Autonumber_Year_Update]
CREATE Procedure [dbo].[SP_Autonumber_Year_Update]
As 
Begin

Update Common.AutoNumber Set preview = replace(preview, '2022', '2023')

END
GO

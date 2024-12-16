USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEEDDATA_COCKPIT_ALL]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_SEEDDATA_COCKPIT_ALL]
@CompanyId BigInt

As
Begin

-- Exec  SP_SEEDDATA_COCKPIT_ALL 1

Begin

Exec [dbo].[SP_SEEDDATA_COCKPIT_CC] @CompanyId

End

Begin 

Exec [dbo].[SP_SEEDDATA_COCKPIT_WF] @CompanyId

End

Begin
Exec [dbo].[SP_SEEDDATA_COCKPIT_HR] @CompanyId

End

Begin
Exec [dbo].[SP_SEEDDATA_COCKPIT_BC] @CompanyId

End

End
GO

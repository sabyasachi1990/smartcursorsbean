USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_AllSP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[BR_AllSP]
@Companyid bigint
AS
BEGIN
Declare  @Err_Msg Nvarchar(max)
Begin Transaction
Begin Try

BEGIN
Exec [dbo].[BR_Migartion_CompanyDetails_SP_New_Devbackup] @Companyid
END

BEGIN
Exec [dbo].[BR_Migartion_EnityDetailsContact_SP_Devbackup] @Companyid
END

BEGIN
Exec [dbo].[BR_Migartion_Contact_SP_New_Devbackup] @Companyid
END

BEGIN
Exec [dbo].[BR_Migartion_Contact_Nominator_SP_New_Devbackup0_Corporate] @Companyid
END

BEGIN
Exec [dbo].[BR_Migartion_Contact_Nominator_SP_New_Devbackup_Individual] @Companyid
END

BEGIN
Exec [dbo].[BR_Migrate_Share_Contact_SP_Devbackup] @Companyid
END

--exec [dbo].[BR_Migrate_Shares_Sp_Devbackup] 2659
BEGIN
Exec [dbo].[BR_Migartion_Auditor_Contact_SP_New_Devbackup] @Companyid
END
		Commit Transaction		
End Try

Begin Catch
	Rollback;
	Set @Err_Msg=(Select ERROR_MESSAGE())
	Raiserror(@Err_Msg,16,1)
End Catch

END

GO

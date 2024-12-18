USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[IncomeTax_Entity_Delete_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[IncomeTax_Entity_Delete_SP](@CompanySetup_Id uniqueidentifier)  
AS
BEGIN
	--=======================================IR8SSectionC================================
	delete from Hr.IR8SSectionC where  IR8SId in (select Id from Hr.IR8S (NOLOCK) where IR8AHRSetUpId in (select Id from Hr.IR8AHRSetUp (NOLOCK) where IR8ACompanySetUpId=@CompanySetup_Id
	))
	--==================================================IR8SSectionA==============================
	delete from Hr.IR8SSectionA  where  IR8SId in (select Id from Hr.IR8S (NOLOCK) where IR8AHRSetUpId in (select Id from Hr.IR8AHRSetUp (NOLOCK) where IR8ACompanySetUpId=@CompanySetup_Id
	))
	--==================================IR8S=============================
	delete from Hr.IR8S where IR8AHRSetUpId in (select Id from Hr.IR8AHRSetUp (NOLOCK) where IR8ACompanySetUpId=@CompanySetup_Id
	)
	--===================================Appendix8A===================================
	delete from Hr.Appendix8A where IR8AHRSetUpId in (select Id from Hr.IR8AHRSetUp (NOLOCK) where IR8ACompanySetUpId=@CompanySetup_Id)
	--============================================IR8AHrSetup==============================================
	if exists (select * from Hr.IR8AHRSetUp (NOLOCK) where Id= @CompanySetup_Id)
	BEGIN
		delete from Hr.IR8AHRSetUp where Id=@CompanySetup_Id
	END
	Else if exists(select * from Hr.IR8AHRSetUp (NOLOCK) where IR8ACompanySetUpId= @CompanySetup_Id)
	BEGIN
		delete from Hr.IR8AHRSetUp where IR8ACompanySetUpId=@CompanySetup_Id
	END
	--===============================================IR8ACompanySetup=================
	if exists(select * from Hr.IR8ACompanySetUp (NOLOCK) where Id=@CompanySetup_Id)
	BEGIN
		delete from Hr.IR8ACompanySetUp where Id=@CompanySetup_Id
	END
END
print 'deletion IncomeTax_Entity_Delete_SP SP Completed'
GO

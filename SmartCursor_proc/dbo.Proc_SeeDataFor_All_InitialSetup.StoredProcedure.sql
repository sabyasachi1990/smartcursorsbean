USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeeDataFor_All_InitialSetup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Proc_SeeDataFor_All_InitialSetup] 
	
	--- exec [dbo].[Proc_SeeDataFor_All_InitialSetup] 2439,1483

 -- 	EXEC   [dbo].[Proc_SeeDataFor_All_InitialSetup] 
	--@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID


     @NEW_COMPANY_ID bigint,
	 @UNIQUE_COMPANY_ID bigint

	 as
	 begin 

	 EXEC  [dbo].[Proc_SeedDataFor_Service_InitialSetup] 
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID

	EXEC [dbo].[Proc_SeeDataFor_HR_InitialSetup] 
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID

	   end 


	
GO

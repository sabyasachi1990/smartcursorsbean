USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ServiceCompanyInActive_Active]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[ServiceCompanyInActive_Active]
@ServiceCompanyId BIGINT,
--@Exists INt output,
@CompanyId int,
@Status int,
@UserName Nvarchar(200)
As
BEGIN
SET NOCOUNT ON;
DECLARE  @ErrorMessage  NVARCHAR(4000),
             @ErrorSeverity INT,
             @ErrorState    INT;
 
      --DECLARE @Exists INT
	Begin Try
		IF EXISTS (SELECT IC.Id FROM Bean.InterCompanySetting IC 
		JOIN Bean.InterCompanySettingDetail ICD On IC.Id=ICD.InterCompanySettingId
		WHERE ICD.ServiceEntityId=@ServiceCompanyId AND IC.CompanyId=@CompanyId AND IC.InterCompanyType='Billing' AND Status=1
		)
		BEGIN 
			Raiserror ('Unable to inactivate service entity because it is mapped in "Service entities under I/B"',16,1)
		End
		ELSE
		  BEGIN
				--SET @Exists = 0
				IF(@Status<>1)
				BEGIN
					If Exists (Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId  and SubsidaryCompanyId=@ServiceCompanyId) --and Status=@Status)
					BEGIN
						Update Bean.ChartOfAccount set Status=@Status,ModifiedBy=@UserName,ModifiedDate=GETUTCDATE() --CASE When @Status=2 Then 1 When @Status=1Then	   2 END 
						where CompanyId=@CompanyId and SubsidaryCompanyId=@ServiceCompanyId --and Status=@Status

						If Exists (Select Id from Common.Bank where CompanyId=@CompanyId  and SubcidaryCompanyId=@ServiceCompanyId )--and Status=@Status)
						BEGIN
								Update Common.Bank set Status=@Status,ModifiedBy=@UserName, ModifiedDate=GETUTCDATE()--CASE When @Status=2 Then 1 When @Status=1Then	   2 END  
								where CompanyId=@CompanyId and SubcidaryCompanyId=@ServiceCompanyId --and Status=@Status
						END
					END
				END
				Update Common.Company set Status=@Status, ModifiedBy=@UserName, ModifiedDate=GETUTCDATE() where Id=@ServiceCompanyId
		  END
	   --RETURN @Exists
	End Try
	Begin Catch
		SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	End Catch
END
GO

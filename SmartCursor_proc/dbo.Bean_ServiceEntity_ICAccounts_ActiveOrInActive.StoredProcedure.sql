USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_ServiceEntity_ICAccounts_ActiveOrInActive]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create     procedure [dbo].[Bean_ServiceEntity_ICAccounts_ActiveOrInActive](@NewCompnayId BIGINT,@ServiceCompanyId BIGINT ,@Status Int)
AS 
Begin
    If Exists (Select * from Bean.ChartOfAccount where CompanyId=@NewCompnayId  and SubsidaryCompanyId=@ServiceCompanyId) --and Status=@Status)
    BEGIN
        Update Bean.ChartOfAccount set Status=@Status --CASE When @Status=2 Then 1 When @Status=1 Then 2 END 
            where CompanyId=@NewCompnayId and SubsidaryCompanyId=@ServiceCompanyId --and Status=@Status

 

            If Exists (Select * from Common.Bank where CompanyId=@NewCompnayId  and SubcidaryCompanyId=@ServiceCompanyId )--and Status=@Status)
            BEGIN
                    Update Common.Bank set Status=@Status--CASE When @Status=2 Then 1 When @Status=1 Then 2 END  
                        where CompanyId=@NewCompnayId and SubcidaryCompanyId=@ServiceCompanyId --and Status=@Status
            END
    END
END
GO

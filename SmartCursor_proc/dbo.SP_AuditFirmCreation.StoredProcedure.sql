USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_AuditFirmCreation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_AuditFirmCreation](@NEW_COMPANY_ID BIGINT)
AS BEGIN
           --------------------CONTROL CODE -----------------
  DECLARE @CONTROL_ID BIGINT,@NEW_CONTROL_ID BIGINT
  DECLARE CONTROL_CURSOR CURSOR FOR 
  SELECT  Id FROM [Common].[ControlCodeCategory] where companyid=0 and( ControlCodeCategoryCode='CommunicationType' or ControlCodeCategoryCode='EntityAddress')
  OPEN CONTROL_CURSOR
  FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID
  WHILE @@FETCH_STATUS=0
  BEGIN   
   SET @NEW_CONTROL_ID = (SELECT MAX(ID) +1 FROM [Common].[ControlCodeCategory])
   INSERT INTO [Common].[ControlCodeCategory] (Id, CompanyId, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType,
   Format, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ModuleNamesUsing, DefaultValue)
   SELECT @NEW_CONTROL_ID, @NEW_COMPANY_ID, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated,
    GETDATE(), ModifiedBy, ModifiedDate, Version, status, ModuleNamesUsing, DefaultValue FROM [Common].[ControlCodeCategory] WHERE ID=@CONTROL_ID
   INSERT INTO [Common].[ControlCode] (Id, ControlCategoryId, CodeKey, CodeValue, IsSystem, RecOrder, Remarks, UserCreated, CreatedDate, 
    ModifiedBy, ModifiedDate, Version, Status, IsDefault)
   SELECT ROW_NUMBER() OVER(ORDER BY a.ID) + (SELECT MAX(Id) + 1 FROM [Common].[ControlCode]) AS Id,@NEW_CONTROL_ID, a.CodeKey, a.CodeValue,
    a.IsSystem, a.RecOrder, a.Remarks, a.UserCreated, GETDATE(), a.ModifiedBy,a.ModifiedDate, a.Version, a.Status, a.IsDefault 
    from  [Common].[ControlCode] a join [Common].[ControlCodeCategory] b on a.controlcategoryid=b.id where b.companyid=0 
    and a.controlcategoryid=@CONTROL_ID
            
   FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID
  END 
  close CONTROL_CURSOR
  Deallocate CONTROL_CURSOR
END
GO

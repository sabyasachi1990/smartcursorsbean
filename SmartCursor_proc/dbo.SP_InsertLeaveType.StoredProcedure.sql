USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsertLeaveType]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_InsertLeaveType]  --Exec SP_InsertLeaveType 1
@CompanyId bigint
AS
Begin

	Declare @Getdate DateTime2=Getdate()
	Declare @ChildcareLeaveTypeId uniqueidentifier
	---Declare @CompanyId  bigint=1

  DECLARE db_LeaveType CURSOR FOR 
  Select Id from Common.Company where status=1 ---and Id=@CompanyId
  
  OPEN db_LeaveType
  FETCH NEXT FROM db_LeaveType INTO @CompanyId  
  
  WHILE @@FETCH_STATUS = 0  
  BEGIN 
BEGIN TRANSACTION --1
BEGIN TRY --1

	--=====================================================Here Check Childcare leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Childcare leave' and CompanyId=@CompanyId and IsMOM=1)
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,IsMOM,LeaveAccuralType,EnableLeaveRecommender,IsSystem)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Childcare leave','System',@Getdate,2,'Days',1,'Yearly without proration',0,1

	   Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
	
	

	--=====================================================Here Check Maternity leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Maternity leave' and CompanyId=@CompanyId and IsMOM=1 )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,IsMOM,LeaveAccuralType ,EnableLeaveRecommender,IsSystem)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Maternity leave','System',@Getdate,2,'Days',1,'Yearly without proration',0,1

	   Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
		--=====================================================Here Check Paternity leaves IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Paternity leaves' and CompanyId=@CompanyId and IsMOM=1 )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,IsMOM,LeaveAccuralType ,EnableLeaveRecommender,IsSystem)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Paternity leaves','System',@Getdate,2,'Days',1,'Yearly without proration',0,1

	   Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
			--=====================================================Here Check Unpaid infant care leave IF Exists or not Exists========================= 
	IF Not Exists ( select id from [HR].[LeaveType] where Name='Unpaid infant care leave' and CompanyId=@CompanyId and IsMOM=1 )
	Begin
	   Set @ChildcareLeaveTypeId =NewId()
	   Insert into [HR].[LeaveType] (Id,CompanyId,Name,UserCreated,CreatedDate,Status,EntitlementType,IsMOM,LeaveAccuralType ,EnableLeaveRecommender,IsSystem)
	   select @ChildcareLeaveTypeId ,@CompanyId,'Unpaid infant care leave','System',@Getdate,2,'Days',1,'Yearly without proration',0,1

	   Insert into [HR].[LEAVETYPEDETAILS] (Id,LeaveTypeId,Status)
	   select NewId(), @ChildcareLeaveTypeId,1
	END
COMMIT TRANSACTION --1
END TRY --1

	   BEGIN CATCH
	   	 ROLLBACK TRANSACTION
	   
	   	 DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;
	   
	   	 SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	   
	   	 RAISERROR (@ErrorMessage, 16, 1);
	   END CATCH
  FETCH NEXT FROM db_LeaveType INTO @CompanyId 
  END 
  CLOSE db_LeaveType 
  DEALLOCATE db_LeaveType
End
GO

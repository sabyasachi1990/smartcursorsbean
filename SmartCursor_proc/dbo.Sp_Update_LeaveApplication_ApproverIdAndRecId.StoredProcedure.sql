USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Update_LeaveApplication_ApproverIdAndRecId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Update_LeaveApplication_ApproverIdAndRecId] (@CompanyID BIGINT)
AS 
BEGIN
 Declare @RecommenderName Varchar(250),
		 @ApproverName Varchar(250),
		 @Id Uniqueidentifier,
		 @RecomenderUserName Varchar(250),
		 @ApproverUserName Varchar(250);		
	     Declare LeaveAppl_CSR Cursor For select Id from HR.LeaveApplication where CompanyId=@CompanyID
			 Open LeaveAppl_CSR
			 Fetch Next From LeaveAppl_CSR Into @id 
			 While @@FETCH_STATUS=0
				 Begin
					 If 1=1
						Begin
						Select @RecomenderUserName=ModifiedBy from HR.HrAuditTrails where [Type]='Leaves' and RecordStatus='Recommended' and TypeId=@Id
							if exists (Select Id from HR.HrAuditTrails where [Type]='Leaves' and RecordStatus='Recommended' and TypeId=@Id)
								Begin
									Update HR.LeaveApplication Set RecommenderUserId=(Select Id From Common.CompanyUser Where FirstName=@RecomenderUserName And CompanyId=@CompanyID)
												Where Id=@Id
								End
						End
					If 1=1
						Begin
						Select @ApproverUserName=ModifiedBy from HR.HrAuditTrails where [Type]='Leaves' and RecordStatus='Approved' and TypeId=@Id
						   	if exists (Select Id from HR.HrAuditTrails where [Type]='Leaves' and RecordStatus='Approved' and TypeId=@Id)
								 Begin
									Update HR.LeaveApplication Set ApproverUserId=(Select Id From Common.CompanyUser Where FirstName=@ApproverUserName And CompanyId=@CompanyID)
												Where Id=@Id
								End
						End						
					Fetch Next From LeaveAppl_CSR Into @id 
				 End
			 Close LeaveAppl_CSR
			 Deallocate LeaveAppl_CSR
END
GO

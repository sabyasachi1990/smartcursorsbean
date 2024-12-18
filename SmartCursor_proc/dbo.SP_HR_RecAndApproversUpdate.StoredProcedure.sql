USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_RecAndApproversUpdate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_HR_RecAndApproversUpdate] (@companyId bigint)

AS 

BEGIN

DECLARE @empId UNIQUEIDENTIFIER,@recs nvarchar(max),@apps nvarchar(max);
DECLARE updaterecandapprovers CURSOR FOR SELECT Id from Common.Employee where CompanyId=@companyId
    OPEN updaterecandapprovers
        FETCH NEXT FROM updaterecandapprovers INTO @empId
        WHILE(@@FETCH_STATUS=0)
        BEGIN
        SELECT @recs= COALESCE(@recs+',' , '') + CAST(  TypeId as nvarchar(50)) from HR.EmployeRecandApprovers as em where Type='Recommender' and EmployeeId=@empId
        SELECT @apps= COALESCE(@apps+',' , '') + CAST(  TypeId as nvarchar(50)) from HR.EmployeRecandApprovers as em where Type='Approver' and EmployeeId=@empId
        update HR.LeaveApplication  set LeaveRecommenderIds=@recs where EmployeeId=@empId 
        --and  LeaveRecommenderIds != 'N/A'
        update HR.LeaveApplication  set LeaveApproverIds=@apps where EmployeeId=@empId 
       -- and  LeaveApproverIds != 'N/A'

         print @recs;
         print @apps;

        set @recs=null;
        set @apps=null;

        FETCH NEXT FROM updaterecandapprovers INTO @empId
        END
    CLOSE updaterecandapprovers
DEALLOCATE updaterecandapprovers
END
GO

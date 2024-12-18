USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Manual_Missing_Claims_Sync]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec HR_Manual_Missing_Claims_Sync 2058
Create Proc [dbo].[HR_Manual_Missing_Claims_Sync] @companyId bigint
As
Begin
Declare @claimTemp table (S_No int identity(1,1),Claimno varchar(200),BeanClaimId uniqueidentifier, ClaimId uniqueidentifier,PostingDate datetime2,ModifiedDate datetime2)
Insert into @claimTemp
select HEC.ClaimNumber,HEC.SyncBCClaimId,HEC.Id,HEC.PostingDate,HEC.ModifiedDate
from HR.EmployeeClaim1 HEC
where HEC.ParentCompanyId = @companyId
and HEC.Ispaycomponent=1 and HEC.ClaimStatus = 'Processed'
Declare @count int = 1
Declare @recCount int = (Select Count(*) from @claimTemp)
Declare @finalTemp table(claimId1 Uniqueidentifier,postingDate DateTime2,modifiedDate datetime2)
Declare @claimNo nvarchar(100)
Declare @claimId uniqueidentifier
Declare @beanBlaimId uniqueidentifier
Declare @postD datetime2
Declare @mDate datetime2
While(@count<= @recCount)
Begin
set @claimNo = (select Claimno from @claimTemp where S_No = @count)
set @claimId = (select ClaimId from @claimTemp where S_No = @count)
set @beanBlaimId = (select BeanClaimId from @claimTemp where S_No = @count)
set @postD = (select PostingDate from @claimTemp where S_No = @count)
set @mDate = (select ModifiedDate from @claimTemp where S_No = @count)
IF Not Exists(Select * from Bean.Journal Where CompanyId = @companyId and docsubtype = 'Claim' and docno = @claimNo AND docType ='Journal')
BEGIN
	IF NOT EXISTS(SELECT * FROM BEAN.JOURNAL WHERE ReverseChildRefId = @claimId)
	Begin
		Insert into @finalTemp
			Select @claimId,@postD,@mDate
	End
END
Set @count = @count+1
End
Select * from @finalTemp
End
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UpdtWF_DesgId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Proc [dbo].[UpdtWF_DesgId] @CompanyId Bigint
As
Begin
Declare
  @CaseDesgId uniqueidentifier,
  @SerGrpId Int,
  @SerId Int,
  @Designation Nvarchar(100)
Declare CaseDesgId_Csr Cursor for
  Select Desg.Id,ServiceGroupId,ServiceId,Designation from WorkFlow.CaseDesignation As Desg
  Inner Join WorkFlow.CaseGroup As CG on CG.Id=Desg.CaseId 
  Where CompanyId=@CompanyId And FeeType='Variable'
 Open CaseDesgId_Csr
 Fetch Next From CaseDesgId_Csr Into @CaseDesgId,@SerGrpId,@SerId,@Designation
 While @@FETCH_STATUS=0
 Begin
 Declare @DeptDesgId Uniqueidentifier
 Select @DeptDesgId=DesignationId from Common.DesignationHourlyRate Where Designation =@Designation  and  ServiceGroupId=@SerGrpId And ServiceId=@SerId
 
 Update WorkFlow.CaseDesignation Set DepartmentDesignationId=@DeptDesgId Where Id=@CaseDesgId

 Fetch Next From CaseDesgId_Csr Into @CaseDesgId,@SerGrpId,@SerId,@Designation

 End

 Close CaseDesgId_Csr;
 Deallocate CaseDesgId_Csr
 End
 
GO

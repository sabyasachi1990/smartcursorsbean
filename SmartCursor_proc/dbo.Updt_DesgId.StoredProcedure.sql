USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Updt_DesgId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Proc [dbo].[Updt_DesgId]
@CompanyId Bigint
As
Begin
Declare @OppDesgId Uniqueidentifier,
  @OppId Uniqueidentifier,
  @ServGroupId Int,
  @Servid Int,
  @Designation nvarchar(100)

Declare Opp_Desg Cursor For
  Select OppDesg.Id,OpportunityId,ServiceGroupId,ServiceId,Designation From ClientCursor.OpportunityDesignation As OppDesg
               Inner Join ClientCursor.Opportunity As Opp on Opp.Id=OppDesg.OpportunityId  Where CompanyId=@CompanyId And FeeType='Variable'
 Open Opp_Desg
 Fetch Next From Opp_Desg Into @OppDesgId,@OppId,@ServGroupId,@Servid,@Designation
 While @@FETCH_STATUS=0
 Begin
 Declare @DesgId Uniqueidentifier
 Select @DesgId=DesignationId from Common.DesignationHourlyRate Where Designation =@Designation  and  ServiceGroupId=@ServGroupId And ServiceId=@Servid
 Update ClientCursor.OpportunityDesignation Set DepartmentDesignationId=@DesgId Where Id=@OppDesgId
 
 Fetch Next From Opp_Desg Into @OppDesgId,@OppId,@ServGroupId,@Servid,@Designation

 End

 Close Opp_Desg
 Deallocate Opp_Desg

End


GO

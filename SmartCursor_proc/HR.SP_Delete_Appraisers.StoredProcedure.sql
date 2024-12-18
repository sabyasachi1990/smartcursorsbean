USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[SP_Delete_Appraisers]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [HR].[SP_Delete_Appraisers] @questionarieId uniqueidentifier, @appraisalId uniqueidentifier,@isSelf bit
AS

 
-- if(@isSelf=1)
-- begin

-- If Exists(Select Id from Hr.Appraisal where Id=@appraisalId and QuestionnaireId=@questionarieId)
--Begin

 

--Update Hr.Appraisal set AppraisersCount=0,IsSelfAppraisal=1 where Id=@appraisalId

 

--If exists(Select Id from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId)
--Begin

 

--If Exists(Select [Id ] from Hr.AppraiseAppraisers where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1))
--   Begin 
--          Delete Hr.AppraiseAppraisers where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1)

 

--  End
--  If Exists(Select [Id] from Hr.AppraiserIncharge where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1))
--   Begin 
--          Delete Hr.AppraiserIncharge where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1)

 

--  End

--End

--End

--end

-- else
 Begin
If Exists(Select Id from Hr.Appraisal where Id=@appraisalId and QuestionnaireId=@questionarieId)
Begin

 

Update Hr.Appraisal set AppraiseesCount=0 , AppraisersCount=0 where Id=@appraisalId

 

If exists(Select Id from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId)
Begin

 

If Exists(Select [Id ] from Hr.AppraiseAppraisers where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1))
   Begin 
          Delete Hr.AppraiseAppraisers where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1)

 

  End
  If Exists(Select [Id] from Hr.AppraiserIncharge where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1))
   Begin 
          Delete Hr.AppraiserIncharge where AppraisalDetailId in (Select ID from Hr.AppraisalAppraiseeDetails where AppraisalId=@appraisalId and IsSelected=1)

 

  End
  Update Hr.AppraisalAppraiseeDetails set IsSelected=0 where AppraisalId=@appraisalId and IsSelected=1

 


End

 

 

End
end

GO

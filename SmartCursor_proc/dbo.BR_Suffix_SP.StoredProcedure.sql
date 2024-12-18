USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Suffix_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    
Create Procedure [dbo].[BR_Suffix_SP]
@CompanId Bigint
As
Begin
Declare @ControlCodeCategoryId Bigint
Declare @MaxId Bigint
Declare @System Varchar(124)
Declare @Temp Table (SuffixId Int,CompType NVarchar(254),CodeKey Nvarchar(1024),CodeValue Nvarchar(1024))
Begin Transaction
Begin Try
Set @System='System'
Select @ControlCodeCategoryId=Id From Common.controlcodeCategory
Where CompanyId=@CompanId and ControlCodeCategoryCode='Company type'

 Set @MaxId=(Select MAX(ISNULL(Id,0)) From Boardroom.Suffix)
 Insert Into @Temp
Select @MaxId + ROW_NUMBER() Over( Order By id) As Id,A.items,CodeKey,CodeValue
From Common.ControlCode
cross apply (Select items From [SplitToTable] (CodeValue,',')) As A
where ControlCategoryId=@ControlCodeCategoryId
 Insert Into Boardroom.Suffix (Id,Name,CompanyId,RecOrder,UserCreated,CreatedDate,Version,Status)
Select @MaxId + ROW_NUMBER() Over( Order By id) As Id,A.items,@CompanId,ROW_NUMBER() Over( Order By id) As RecOrder,@System,CreatedDate,Version,Status
From Common.ControlCode
cross apply (Select items From [SplitToTable] (CodeValue,',')) As A
where ControlCategoryId=@ControlCodeCategoryId
 Set @MaxId=(Select MAX(ISNULL(Id,0)) From Boardroom.CompanyType)
 Insert into Boardroom.CompanyType (Id,Name,CompanyId,RecOrder,UserCreated,CreatedDate,Version,Status)
Select @MaxId + ROW_NUMBER() Over( Order By id) As Id,CodeKey,@CompanId,ROW_NUMBER() Over (Order By Id),@System,CreatedDate,Version,Status
From Common.ControlCode where ControlCategoryId=@ControlCodeCategoryId
 Set @MaxId=(Select MAX(ISNULL(Id,0)) From Boardroom.CompanyTypeSuffix)
 Insert Into Boardroom.CompanyTypeSuffix(Id,CompanyTypeId,SuffixId,RecOrder)
Select @MaxId+ ROW_NUMBER() Over( Order By A.Suffixid) As Id,B.Id,A.SuffixId,ROW_NUMBER() Over( Order By A.Suffixid) As Recorder
From @Temp As A
Inner Join Boardroom.CompanyType As B On A.CodeKey=B.Name
Commit Transaction
End Try
Begin Catch
Rollback
Declare @Err_Msg Nvarchar(Max)=(Select ERROR_MESSAGE())
RaisError(@Err_Msg,16,1)
End Catch
End

GO

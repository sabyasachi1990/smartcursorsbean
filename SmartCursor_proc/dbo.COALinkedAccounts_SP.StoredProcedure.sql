USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[COALinkedAccounts_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure  [dbo].[COALinkedAccounts_SP]
@Ids Nvarchar(Max),
@DocType Nvarchar(250),
@CusrsorName Nvarchar(250),
@CompanyId BigInt,
@CreateBy Nvarchar(250)
As
Begin
	Begin Transaction
--Declare @COATbl Table (OldCoaId Nvarchar(50),NewCoaId Nvarchar(50),DocId Nvarchar(250),CompanyId Bigint,DocType Nvarchar(250),CursorName Nvarchar(250),CreatedBy Nvarchar(250))


	Declare @Item nvarchar(250),
			@Id Nvarchar(250),
			@Count Int,
			@OldCoaId Varchar(50),
			@NewCoaId  Varchar(50),
			@DocId Nvarchar(250),
			@IsLinkedAccount Int,
			@Err_Msg Nvarchar(4000)
		
	Begin Try
		-- // Declare First Cursor To Split Multiple OldCoaId,NewCoaId & DocId Sets Using ':'
		Declare IDSplit_CSR Cursor For
			Select items from dbo.SplitToTable(@Ids,':')
		Open IDSplit_CSR
		Fetch Next From IDSplit_CSR Into @Item
		While @@FETCH_STATUS=0
		Begin
			Set @Count=0
		--// Declare Second Cursor To Split The Set Of Id's From First Cursor
			Declare ItemSolit_CSR Cursor For
				Select items from dbo.SplitToTable(@Item,',')
			Open ItemSolit_CSR
			Fetch Next From ItemSolit_CSR Into @Id
			While @@FETCH_STATUS=0
			Begin
				Set @Count=@Count+1
				If @Count=1
				Begin
				Set @OldCoaId=@Id
				End
				If @Count=2
				Begin
				Set @NewCoaId=@Id
				End	
				If @Count=3
				Begin
				Set @DocId=@Id
				End	
				Fetch Next From ItemSolit_CSR Into @Id
			End
		--// Closing Second Cursor
			Close ItemSolit_CSR 
			Deallocate ItemSolit_CSR
			IF @NewCoaId Is Not Null And @NewCoaId<>0 /*And @OldCoaId Is Not Null And @OldCoaId<>0*/
			Begin
				If  @OldCoaId Is Not Null And @OldCoaId<>0
				Begin
					Set @IsLinkedAccount=0
					If Exists (Select Id From Bean.Item (NOLOCK) where CompanyId=@CompanyId And COAId=@OldCoaId and IsExternalData=1 and IsIncidental=1)
					Begin
						Set @IsLinkedAccount=1
					End
					Else If Exists (Select Id From Common.Service (NOLOCK) where CompanyId=@CompanyId And CoaId=@OldCoaId And cast( Id as nvarchar(50))<>  @DocId)
					Begin
						Set @IsLinkedAccount=1
					End
					Else If Exists (Select Id From WorkFlow.IncidentalClaimItem (NOLOCK) where CompanyId=@CompanyId And COAId=@OldCoaId)
					Begin
						Set @IsLinkedAccount=1
					End
					Else If Exists (Select Id From HR.ClaimItem (NOLOCK) where CompanyId=@CompanyId And COAId=@OldCoaId)
					Begin
						Set @IsLinkedAccount=1
					End
					Else If Exists (Select Id From HR.PayComponent (NOLOCK) where CompanyId=@CompanyId And COAId=@OldCoaId)
					Begin
						Set @IsLinkedAccount=1
					End
					IF @IsLinkedAccount=1
					Begin
						Update Bean.ChartOfAccount Set IsLinkedAccount=1,IsSystem=0 Where Id = @OldCoaId And CompanyId=@CompanyId And Not Exists (Select Id From Bean.ChartOfAccount (NOLOCK) Where Id=@OldCoaId And IsLinkedAccount=1 And CompanyId=@CompanyId)
					End
					Else
					Begin
						Update Bean.ChartOfAccount Set IsLinkedAccount=0,IsSystem=Null Where Id = @OldCoaId And CompanyId=@CompanyId And Exists (Select Id From Bean.ChartOfAccount (NOLOCK) Where Id=@OldCoaId And IsLinkedAccount=1 And CompanyId=@CompanyId)
					End
				End
				-- New COAid Updation
				Update Bean.ChartOfAccount Set IsLinkedAccount=1,IsSystem=0 Where Id = @NewCoaId And CompanyId=@CompanyId And Not Exists (Select Id From Bean.ChartOfAccount (NOLOCK) Where Id=@NewCoaId And IsLinkedAccount=1 And CompanyId=@CompanyId)
			End	
			Fetch Next From IDSplit_CSR Into @Item
		End
		Close IDSplit_CSR
		Deallocate IDSplit_CSR
		Commit Transaction

	End Try

	Begin Catch
	
		Rollback
		Select @Err_Msg=ERROR_MESSAGE()
		RaisError(@Err_Msg,16,1);
	
	End Catch
End
GO

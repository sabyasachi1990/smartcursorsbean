USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF.Opportunity_Stage_Updated]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




Create Proc [dbo].[WF.Opportunity_Stage_Updated] 
@Id Varchar(max),
@ReasonForCancellation nvarchar(500), 
@Stage nvarchar(50),
@ModifiedBy nvarchar(500),
@ModifiedDate datetime2,
@Remarks nvarchar(500),
@CompanyId bigint=15

As
Begin

--Exec [dbo].[WF.Opportunity_Stage_Updated] 'D919F398-44BD-4950-94C5-003C1767B93C,578D7250-2499-888A-611A-05A54E4F3BC1','other','Cancelld','Suresh.pang@precursor.com.sg','2019-03-08 06:11:45.3933333',
--'discounted rate given to client',15

--Declare @Id Varchar(max) ='D919F398-44BD-4950-94C5-003C1767B93C,578D7250-2499-888A-611A-05A54E4F3BC1',
--@ReasonForCancellation nvarchar(500)='other', 
--@Stage nvarchar(50)='Cancelld',
--@ModifiedBy nvarchar(500)='ruiyeh.pang@precursor.com.sg',
--@ModifiedDate datetime2=getdate(),
--@Remarks nvarchar(500)='discounted rate given to client',
--@CompanyId bigint=15

--set @Stage='Cancelled'
Declare @Item table (id uniqueidentifier)

Insert Into @Item
Select items from [dbo].[SplitToTable] (@id,',')

--select * from @Item

Declare Opp_Update Cursor For
Select * from @Item

Open Opp_Update
Fetch Next From Opp_Update Into @Id
      While @@FETCH_STATUS=0
				 Begin

				 if Exists(select id from ClientCursor.Opportunity where id=@Id)
				 Begin
				update  ClientCursor.Opportunity  set ReasonForCancellation=@ReasonForCancellation,Stage=Case When @Stage='Cancelled' then 'Cancelled' when @stage='Complete' Then 'Complete' END,
				ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate,Remarks=@Remarks,CompanyId=@CompanyId from ClientCursor.Opportunity where id=@id --and Companyid=@Companyid
			

				Insert into ClientCursor.OpportunityStatusChange
				select NEWID(),@Companyid,@id,@Stage,@ModifiedBy,@ModifiedDate from ClientCursor.Opportunity where id=@id --and Companyid=@Companyid

                Fetch Next From Opp_Update Into @Id
				 END
				 END
				 
			 Close Opp_Update
			 Deallocate Opp_Update

			 END
GO

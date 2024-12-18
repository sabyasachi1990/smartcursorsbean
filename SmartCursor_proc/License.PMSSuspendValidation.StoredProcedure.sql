USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [License].[PMSSuspendValidation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [License].[PMSSuspendValidation] (
@subscriptionId Uniqueidentifier)
as Begin
Declare @CopmanyId Bigint = (select CompanyId from License.Subscription where Id=@subscriptionId)
Declare @subName nvarchar(50) = (select SubscriptionName from License.Subscription where Id=@subscriptionId)
if(@subName like '%Practice Management (1-50)%')
Begin
Declare @SubscriptionName1 nvarchar(50) =  (select top(1) SubscriptionName from License.Subscription where CompanyId=@CopmanyId and Status=1 and (SubscriptionName like '%Practice Management (51-100)%' or SubscriptionName like '%Practice Management (>100)%'))
if(@SubscriptionName1 is not null)
Begin
Begin
			 declare @exception1 nvarchar(500) = concat('You can not have both packages together ' , @subName , @SubscriptionName1)
			end
			 raiserror(@exception1,16,1)
End
End
Begin
if(@subName like '%Practice Management (51-100)%')
Begin
Declare @SubscriptionName2 nvarchar(50) =  (select top(1) SubscriptionName from License.Subscription where CompanyId=@CopmanyId and Status=1 and (SubscriptionName like '%Practice Management (1-50)%' or SubscriptionName like '%Practice Management (>100)%'))
if(@SubscriptionName2 is not null)
Begin
Begin
			 declare @exception2 nvarchar(500) = concat('You can not have both packages together' , @subName , @SubscriptionName2)
			end
			 raiserror(@exception2,16,1)
End
End

if(@subName like '%Practice Management (>100)%')
Begin
Declare @SubscriptionName3 nvarchar(50) =  (select top(1) SubscriptionName from License.Subscription where CompanyId=@CopmanyId and Status=1 and (SubscriptionName like '%Practice Management (1-50)%' or SubscriptionName like '%Practice Management (51-100)%'))
if(@SubscriptionName3 is not null)
Begin
Begin
			 declare @exception3 nvarchar(500) = concat('You can not have both packages together ' , @subName , @SubscriptionName3)
			end
			 raiserror(@exception3,16,1)
End
End
End
End
GO

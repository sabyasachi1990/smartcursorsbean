USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Delete_IdentityData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Delete_IdentityData]
As
Begin
	Begin Transaction
	Begin Try
		Print 'Boardroom.InCharge'
		Delete From Boardroom.InCharge Where UserAccountId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'ClientCursor.AccountNote'
		Delete From ClientCursor.AccountNote Where UserId In (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'ClientCursor.VendorNote'
		Delete From ClientCursor.VendorNote where UserId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Common.UserAccountCursors'
		Delete From Common.UserAccountCursors where UserAccountId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Support.TicketHistory'
		Delete From Support.TicketHistory Where TicketId In (Select Id From Support.Ticket Where UserId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser)))
		
		Print 'Support.TicketReply'
		Delete From Support.TicketReply Where UserId in (Select Id From Support.Ticket Where UserId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser)))
		
		Print 'Support.Ticket'
		Delete From Support.Ticket Where UserId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Support.TicketReply'
		Delete From Support.TicketReply Where UserId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))

		Print 'Widget.ActivityNotificationDetail'
		Delete From Widget.ActivityNotificationDetail Where ParticipentId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))

		Print 'Widget.ActivityParticipent'
		Delete From Widget.ActivityParticipent Where ParticipentId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Widget.ActivityReplyAttachment'
		Delete From Widget.ActivityReplyAttachment Where ActivityReplyId in (Select Id From Widget.ActivityReply Where ReplyById in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser)))
		
		Print 'Widget.ActivityReplyParticipent'
		Delete From Widget.ActivityReplyParticipent Where ActivityReplyId in (Select Id From Widget.ActivityReply Where ReplyById in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser)))
		
		Print 'Widget.ActivityReplyParticipent'
		Delete From Widget.ActivityReplyParticipent Where ParticipentId in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Widget.ActivityReply'
		Delete From Widget.ActivityReply Where ReplyById in (Select Id From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))

		Print '[SCIdentityPRDLive].dbo.AspNetUserRoles'
		Delete From [SCIdentityPRDLive].dbo.AspNetUserRoles Where UserId In (Select Id From [SCIdentityPRDLive].[dbo].[AspNetUsers] Where id in (Select UserId From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))) 

		Print '[SCIdentityPRDLive].dbo.AspNetUserLogins'
		Delete From [SCIdentityPRDLive].dbo.AspNetUserLogins Where UserId In (Select Id From [SCIdentityPRDLive].[dbo].[AspNetUsers] Where id in (Select UserId From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))) 
		
		Print '[SCIdentityPRDLive].dbo.AspNetUserClaims'
		Delete From [SCIdentityPRDLive].dbo.AspNetUserClaims Where UserId In (Select Id From [SCIdentityPRDLive].[dbo].[AspNetUsers] Where id in (Select UserId From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))) 
		
		Print '[SCIdentityPRDLive].[dbo].[AspNetUsers]'
		Delete From [SCIdentityPRDLive].[dbo].[AspNetUsers] Where id in (Select UserId From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser))
		
		Print 'Auth.UserAccount'
		Delete From Auth.UserAccount Where Id not in (Select UserId From Common.CompanyUser)

		Commit Transaction
	End Try
	Begin Catch
		Rollback;
		Select ERROR_MESSAGE()
	End Catch
End
GO

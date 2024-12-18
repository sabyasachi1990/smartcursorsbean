USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Replacescmuserid_with_ExternalUserId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Replacescmuserid_with_ExternalUserId]

--- Exec [dbo].[Replacescmuserid_with_ExternalUserId] 'Narendra@yopmail.com','Narendra@zirafftechnologies.com','Narendra@zirafftechnologies.com','SCIdentityTST'

@ScmuserId varchar(500),
@ExternalUserId varchar(500),
@ExternalEmail  varchar(500),
@IdentityDBName nvarchar(500)

 
--Declare @ScmuserId varchar(500)='Claz2@smartcursors.org',
--@ExternalUserId varchar(500)='Pavan@smartcursors.org',
--@IdentityDBName nvarchar(400)='SmartCursorOfficeIdentity'


AS
BEGIN

 

 Declare @Count int
declare @query nvarchar(2000);
Declare @ErrorMessage Nvarchar(4000)
Declare @DynSql Nvarchar(Max)
Begin Transaction
Begin Try


      Set @query = 'select @Count=Count(*)  from '+ @IdentityDBName +'.dbo.AspNetUsers where Username=@ScmuserId';
    execute sp_executesql @query, N'@Count int Output, @ScmuserId varchar(500)', @Count out, @ScmuserId=@ScmuserId 
    If @Count<1
    Begin
        Set @ErrorMessage='SCM User Not existing in Identity'
        Raiserror('More than once occured',16,1);
    End

    --Select @Count=Count(*) From [@IdentityDBName].[dbo].[AspNetUsers] Where Username=@ExternalUserId
    Set @query = 'Select @Count=Count(*) from '+ @IdentityDBName +'.dbo.AspNetUsers where Username=@ExternalUserId';
    execute sp_executesql @query, N'@Count int Output, @ExternalUserId varchar(500)', @Count out, @ExternalUserId=@ExternalUserId 
    If @Count=1
    Begin
        Set @ErrorMessage='Office365 User already exists in Identity'
        Raiserror('More than once occured',16,1);
    End

	--------------------------
	--Set @query = 'Select @Count=Count(*) from '+ @IdentityDBName +'.dbo.AspNetUsers where Email=@ExternalEmail';
 --   execute sp_executesql @query, N'@Count int Output, @ExternalEmail varchar(500)', @Count out, @ExternalEmail=@ExternalEmail 
    --If @Count=1
    --Begin
    --    Set @ErrorMessage='Office365 User already exists in Identity'
    --    Raiserror('More than once occured',16,1);
    --End
	-----------------------


    Declare @TotalCount int
    Declare @Exite varchar(500)
    Declare @Inside varchar(500)
	Declare @ExterEmail varchar(500)


    --Exec (@IdentityDBName)

    set @TotalCount=@Count
    set @Inside=@ScmuserId
    set @Exite=@ExternalUserId
	set @ExterEmail=@ExternalEmail
    
    --select @TotalCount
    --select @ScmuserId
    --select @ExternalUserId
    --select @IdentityDBName

 
 Update AA set AA.oldusername=AA.NewUserName From
    (
        select username as oldusername,REPLACE(username,@ScmuserId,@ExternalUserId) AS NewUserName from auth.useraccount A
		where Username=@ScmuserId
    )AS AA

 
    Update bb set bb.oldusername=bb.NewUserName From
    (
        select e.Username AS OldUsername,REPLACE(username,@ScmuserId,@ExternalUserId)AS NewUserName from common.employee e
		where e.Username=@ScmuserId
    )AS bb



    update cc set CC.oldusername=cc.NewUserName From
    (
        select C.username AS oldusername ,REPLACE(username,@ScmuserId,@ExternalUserId)AS NewUserName from Common.CompanyUser C
		where C.username=@ScmuserId
    )AS cc
	------------Add New table Auth.UserAccount and Common.CompanyUser------
	update dd set dd.oldusername=dd.NewUserName From
    (
        select c.Email AS oldusername ,REPLACE(Email,@ScmuserId,@ExternalEmail)AS NewUserName from Common.CompanyUser c
		where c.Email=@ScmuserId
    )AS dd


	update ee set ee.oldusername=ee.NewUserName From
    (
        select e.Email AS oldusername ,REPLACE(e.Email,@ScmuserId,@ExternalEmail)AS NewUserName from Auth.UserAccount  e
		where e.Email=@ScmuserId
    )AS ee

	-------------------
	Set @DynSql='update dd set dd.oldUserName=(dd.NewUserName) From
    (
        select  ANU.UserName AS oldUserName,REPLACE(ANU.UserName,'''+ @ScmuserId + ''',''' + @ExternalUserId + ''')AS NewUserName from ' + @IdentityDBName + '.[dbo].[AspNetUsers] AS ANU
		where anu.username='''+ @ScmuserId +'''
    )AS dd'
	--Print @DynSql

	Exec (@DynSql)


   Set @DynSql='update ee set ee.oldEmail=(ee.NewEmail) From
   (
   select  ANU.Email AS oldEmail,REPLACE(ANU.Email,'''+ @ScmuserId + ''',''' + @ExternalUserId + ''')AS NewEmail from ' + @IdentityDBName + '.[dbo].[AspNetUsers] AS ANU
   where ANU.Email='''+ @ScmuserId +'''
   )AS ee'
   Print @DynSql
   Exec (@DynSql)

    Set @DynSql='update ff set ff.oldNormalizedEmail=Upper(ff.NewNormalizedEmail) From
   (
   select  ANU.NormalizedEmail AS oldNormalizedEmail,REPLACE(ANU.NormalizedEmail,'''+ @ScmuserId + ''',''' + @ExternalUserId + ''') AS NewNormalizedEmail from ' +@IdentityDBName + '.[dbo].[AspNetUsers] AS ANU
  where ANU.NormalizedEmail='''+ @ScmuserId +'''
   )AS ff'
   Print @DynSql
   Exec (@DynSql)
   
   Set @DynSql='update gg set  gg.oldNormalizedUserName=Upper(gg.NewNormalizedUserName) From
   (
   select  ANU.NormalizedUserName AS oldNormalizedUserName,REPLACE(ANU.NormalizedUserName,'''+ @ScmuserId + ''',''' + @ExternalUserId + ''') AS NewNormalizedUserName from ' + @IdentityDBName + '.[dbo].[AspNetUsers] AS ANU
   Where ANU.NormalizedUserName='''+ @ScmuserId +'''
   )AS gg'
   Print @DynSql
    Exec (@DynSql)


    Commit Transaction
   End Try
   Begin Catch 
	 Rollback Transaction;
	 --Select @ErrorMessage=ERROR_MESSAGE()
	 Raiserror(@ErrorMessage,16,1)
   End Catch

END
GO

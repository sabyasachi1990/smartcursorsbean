USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Adress_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [dbo].[Import_Adress_Validation]

 --- Exec Import_Adress_Validation  '3D682EA1-2DA1-48BB-9729-845EB1C03EA6'

 @TransactionId uniqueidentifier
  as 
  begin 

declare ---@TransactionId uniqueidentifier='3D682EA1-2DA1-48BB-9729-845EB1C03EA6',
  @id Uniqueidentifier,
  @ContactName Nvarchar(max),
  @MasterId NVARCHAR(MAX),
  @PersonalLocal Nvarchar(Max),
  @PersonalForeign Nvarchar(Max),
  @EntityLocal Nvarchar(Max),
  @EntityForeign Nvarchar(Max),
  @LocalAddress Nvarchar(Max),
  @ForeignAddress Nvarchar(Max)
 Declare Address_Get Cursor For
select Id,Name as ContactName,ClientRefNumber,
PersonalLocalAddress,PersonalForeignAddress,EntityLocalAddress,EntityForeignAddress
 from  ImportWFContacts where TransactionId=@TransactionId	AND ( ImportStatus<>0 oR  ImportStatus IS NULL) 
        Open Address_Get
		fetch next from Address_Get Into @id,@ContactName,@MasterId,@PersonalLocal,@PersonalForeign,@EntityLocal,@EntityForeign
		While @@FETCH_STATUS=0
		Begin
	  If @PersonalLocal Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@PersonalLocal,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFContacts set ErrorRemarks = 'PersonalLocalAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId AND Id=@id AND Name=@ContactName AND ClientRefNumber= @MasterId AND PersonalLocalAddress= @PersonalLocal AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END 


	     If @PersonalForeign Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@PersonalForeign,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFContacts set ErrorRemarks = 'PersonalForeignAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId AND Id=@id AND Name=@ContactName AND ClientRefNumber= @MasterId AND PersonalForeignAddress= @PersonalForeign AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END 

	     If @EntityLocal Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@EntityLocal,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFContacts set ErrorRemarks = 'EntityLocalAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId AND Id=@id AND Name=@ContactName AND ClientRefNumber= @MasterId AND EntityLocalAddress= @EntityLocal AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END
	    
	     If @EntityForeign Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@EntityForeign,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFContacts set ErrorRemarks = 'EntityForeignAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId AND Id=@id AND Name=@ContactName AND ClientRefNumber= @MasterId AND EntityForeignAddress= @EntityForeign AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END 


	   If Exists ( SELECT ClientRefNumber  FROM ImportWFClient WHERE TransactionId=@TransactionId AND ClientRefNumber= @MasterId)
		 Begin
		  SET @LocalAddress=( SELECT LocalAddress  FROM ImportWFClient WHERE TransactionId=@TransactionId AND ClientRefNumber= @MasterId)
		   SET @ForeignAddress=( SELECT ForeignAddress  FROM ImportWFClient WHERE TransactionId=@TransactionId AND ClientRefNumber= @MasterId)
	      If @LocalAddress Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@LocalAddress,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFClient set ErrorRemarks = 'LocalAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId  AND ClientRefNumber= @MasterId AND LocalAddress= @LocalAddress AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END


	     If @ForeignAddress Is NOT  Null
		 Begin
      if NOT Exists (SELECT Value FROM (Select  COUNT(Value)  AS Value From string_split(@ForeignAddress,',') )HH WHERE Value=6)
	    Begin
		 Update ImportWFClient set ErrorRemarks = 'LocalAddress  not correct format', ImportStatus=0
		 where  TransactionId=@TransactionId  AND ClientRefNumber= @MasterId AND ForeignAddress= @ForeignAddress AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	   END 
	   END
	    
	   END


 fetch next from Address_Get Into  @id,@ContactName,@MasterId,@PersonalLocal,@PersonalForeign,@EntityLocal,@EntityForeign
	End
	Close Address_Get
	Deallocate Address_Get
	end 

 







GO

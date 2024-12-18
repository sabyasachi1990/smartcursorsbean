USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_GenerateDocNo]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



----Declare @DocNo nvarchar(30)
----Exec Common_GenerateDocNo 1005,'Bean Cursor','Invoice',1,@DocNo out
----select @DocNo

----select * from Common.AutoNumber where CompanyId=244 and EntityType='Invoice'

----update Common.AutoNumber set Format='INV-{MM/YYYY}-' where CompanyId=244 and EntityType='Invoice'

----select ParentId,* from Common.Company order by CreatedDate desc

--ALTER Procedure [dbo].[Common_GenerateDocNo]  
--(  
--@CompanyId BigInt,  
--@CursorName NVARCHAR(80),  
--@EntityType NVARCHAR(100),  
--@IsAdd bit,  
--@DocNo Nvarchar(100) OutPut  
--)  


--AS   
--BEGIN  
-- Declare @AutoTemp Table(Id UniqueIdentifier,CompanyId BigInt,ModuleMasterId BigInt,EntityType Nvarchar(100),Format Nvarchar(100),GeneratedNumber Nvarchar(100),CLength Int,StartNumber bigint,Reset Nvarchar(40),Preview NvarChar(100),IsEditable Bit,IsEditableDisable Bit)  
 
 
-- Declare @modulemasterId BigInt,  
--   @generatedNumber Nvarchar(50),  
--   @format Nvarchar(100),  
--   @isEditable bit,  
--   @LastDocNo Nvarchar(50),  
--   @lastCreatedDate DateTime,  
--   @counter int=0,  
--   @AutoNumberType NvarChar(80),  
--   @Isexists bit

--  BEGIN TRY  
--   Select @modulemasterId=m.Id from Common.ModuleMaster as m (NOLOCK) where Name=@CursorName and CompanyId=0  
   
--   if(@CursorName ='Bean Cursor')
--   BEGIN 
--   SELECT @Isexists = CASE 
--                      WHEN EXISTS (Select Id from Bean.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
--                      THEN 1
--                      ELSE 0
--					  END
--   END

--   else
--   BEGIN
--   SELECT @Isexists = CASE 
--                      WHEN EXISTS (Select Id from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
--                      THEN 1
--                      ELSE 0
--					  END
--   END


--   --Select Id from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType

--   IF(@Isexists = 1)  
--   BEGIN--If AutoNumber is Exist  
   
--   if(@CursorName ='Bean Cursor')
--   BEGIN
--	Insert Into @AutoTemp 
--	Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview,IsEditable,IsEditableDisable 
--	from Bean.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType  
--   END

--   else
--   BEGIN
--	Insert Into @AutoTemp 
--	Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview,IsEditable,IsEditableDisable 
--	from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType  
--   END

--    --If(@CursorName='Bean Cursor' and (@EntityType='Invoice')OR(@EntityType='Credit Note')OR(@EntityType='Debt Provision'))  
--    Set @AutoNumberType=@EntityType;  
--    If(@CursorName='Bean Cursor')  
--    Begin--If cursor name Bean  
       
--     If(@EntityType='Payroll Payment')  
--      Begin  
--       Set @EntityType='Payroll';  
--      END  
--      Else If(@EntityType='Payment')  
--      Begin  
--       Set @EntityType='General';  
--      END  
--      Else If(@EntityType='Recurring Journal')  
--      Begin  
--       Set @EntityType='Recurring';  
--      End  
--    End  
--     SET @isEditable=(select t.IsEditable from @AutoTemp as t)  
--     IF(@isEditable=1)   
--     BEGIN--If it is Editable  
        
--		Set @LastDocNo = (select [dbo].[Common_GetLastDocNo](@CompanyId,@CursorName,@EntityType))  
--		If(@LastDocNo Is Not Null)  
--		BEGIN 
--			IF(ISNUMERIC(Left(Reverse(@lastDocNo),1))=1)  
--			BEGIN  
--				Set @DocNo=(select dbo.GetNextSequenceNumber(@lastDocNo,@CompanyId,@EntityType))  
--			END  
			
--			Else  
--			BEGIN  
--				SET @DocNo= @lastdocno+ Cast(1 as varchar(5));  
--				If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--				Begin  
--					Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
--				End  
--			END  
--		END--END of Invoice is Exists  
--		Else  
--		BEGIN  
--			Set @DocNo=(Select a.Preview from @AutoTemp as a) 
--		END  
--     END--End of is Editable  
--     ELSE  
--     BEGIN--If it is Auto-Number  
--		Set @LastDocNo= (select [dbo].[Common_GetLastDocNo](@CompanyId,@CursorName,@EntityType))  
--		If(@LastDocNo is not null)  
--		BEGIN--If Invoice is Exists  
--       --Set @LastDocNo = (select [dbo].[Common_GetLastDocNo](@CompanyId,@CursorName,@EntityType))  
--		--Set @lastCreatedDate=(select [dbo].[Common_GetLastCreatedDate](@CompanyId,@CursorName,@EntityType))  
--       --Select @lastDocNo=i.DocNo,@lastCreatedDate=i.CreatedDate from Bean.Invoice as i where CompanyId=@CompanyId and DocType=@EntityType and (IsWorkFlowInvoice is null or IsWorkFlowInvoice<>1) order by CreatedDate desc  
--		Select @format=a.Format from @AutoTemp as a  
--		IF(@format Like '%{MM/YYYY}%')  
--		BEGIN--If contains the Month Format  
--        --IF(@lastDocNo<>(select t.Preview from @AutoTemp as t))  
--        --BEGIN--If doc no exist  
--         --IF(MONTH(@lastCreatedDate)<>MONTH(GETUTCDATE()))  
--         --BEGIN--If Last Created Month and Current Month is not same  
--         -- select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As      varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(1)) + cast (t.StartNumber as   varchar) from  @AutoTemp as t  
--         -- If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--         -- Begin  
--         --  Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
--         --  if(@IsAdd=0)  
--         --  Begin  
--         --   Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType and    ModuleMasterId=@modulemasterId  
--         --  End  
--         -- END  
--         --END--ENd of Last Created Month and Current Month is not same  
--         --ELSE  
--         --BEGIN--If Month is same  
--			select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As      varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(t.GeneratedNumber)) + cast (t.GeneratedNumber as varchar) from  @AutoTemp as t  
--			If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--			Begin--If exists   
--				select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As      varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(t.GeneratedNumber+1)) + cast   (t.GeneratedNumber+1 as varchar) from @AutoTemp as t  
            
--				If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--				Begin  
--					Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
--					If(@IsAdd=0)  
--					Begin 
					
--					 if(@CursorName ='Bean Cursor')
--					 BEGIN
--					 Update Bean.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
--					 END

--					 else
--					 BEGIN
--						Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
--					 END
--					End  
--			END  
--			Else  
--			Begin  
--				If(@IsAdd=0)  
--				Begin  

--				 if(@CursorName ='Bean Cursor')
--					 BEGIN
--					 Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
--					 END

--					 else
--					 BEGIN
--					 Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
--					 END
--				End  
--			End  
--          End--End of If exists  
--          Else  
--          Begin  
--           Set @DocNo=@DocNo;  
--           --Update Common.AutoNumber SET GeneratedNumber=(Select t.StartNumber from @AutoTemp t)      where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId
--			If(@IsAdd=0)  
--			Begin  

--			if(@CursorName ='Bean Cursor')
--			BEGIN
--				Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
--			END

--			else
--			BEGIN
--				Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
--			END
--			End 
--          End  
--         --END--End of Month is same  
--        --END-- End of doc no exist  
--       END--End of Month format  
--       ELSE--If not contains Month format   
--       BEGIN  
--        --IF(YEAR(@lastCreatedDate)<>YEAR(GETUTCDATE()))  
--        --BEGIN--IF year is changed  
--        -- select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(1)) + cast (t.StartNumber as varchar) from @AutoTemp as t  
--        -- If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--        -- Begin  
--        --  Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
--        --  If(@IsAdd=0)  
--        --  Begin  
--        --   Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select t.CLength   from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType and       ModuleMasterId=@modulemasterId  
--        --  End  
--        -- END  
  
--        --END--End of year changed  
--        --ELSE  
--        --BEGIN--IF year is same  
--         select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(t.GeneratedNumber)) + cast (t.GeneratedNumber as varchar) from @AutoTemp as t  
--         IF ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--         Begin-- If Exists  
--          select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE())) + replicate('0', t.CLength - len    (t.GeneratedNumber+1)) + cast (t.GeneratedNumber+1 as varchar) from @AutoTemp as t  
--          If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
--           Begin  
--            Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
--            If(@IsAdd=0)  
--            Begin
			

--			if(@CursorName ='Bean Cursor')
--			BEGIN
--             Update Bean.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId
--			 END

--			 else
--			 BEGIN
--			  Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
--			 END

--            End  
--           END  
--          Else  
--          BEGIN  
--           If(@IsAdd=0)  
--           Begin  

--		   	if(@CursorName ='Bean Cursor')
--			BEGIN
--				Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
--			END

--			else
--			BEGIN
--			Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
--			END

--           End  
--          End  
--         End--End Of If Exists  
--         Else  
--         Begin  
--			Set @DocNo=@DocNo;  
--          --Update Common.AutoNumber SET GeneratedNumber=(Select t.StartNumber from @AutoTemp t) where     CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
--			If(@IsAdd=0)  
--			Begin  

--			 	if(@CursorName ='Bean Cursor')
--			    BEGIN
--				Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
--				END

--				else
--				BEGIN
--				Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
--				END
--			End 
--         End  
--        --END--End of Year is Same  
--       END--END of not contains Month format   
--      END--End of Invoice Exists  
--      ELSE  
--      BEGIN--If Invoice not exists  
--       Select @format=a.Format from @AutoTemp as a  
--       IF(@format Like '%{MM/YYYY}%')  
--       BEGIN--If contains month and year  
--        select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(1)) + cast (1 as varchar) from @AutoTemp as t  
--       END  
--       ELSE  
--       BEGIN  
--        select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(1)) + cast (1 as varchar) from @AutoTemp as t  
--       END  
--      END--END of If Invoice not exists  
--     END--End of Auto-Number  
--    --END--End of If cursor name is Bean and Entity Type is Invoice   
      
--   END--End of Auto-Number Exists  
--  END TRY  
--  BEGIN CATCH  
--  END CATCH  
--END

-----------------------  Old SP -----Completed ----------------------------------------------



-----------------------New SP Start ----------------------------------------------------------


CREATE   Procedure [dbo].[Common_GenerateDocNo]  
(  
@CompanyId BigInt,  
@CursorName NVARCHAR(80),  
@EntityType NVARCHAR(100),  
@IsAdd bit,  
@DocNo Nvarchar(100) OutPut  
)  


AS   
BEGIN  
 Declare @AutoTemp Table(Id UniqueIdentifier,CompanyId BigInt,ModuleMasterId BigInt,EntityType Nvarchar(100),Format Nvarchar(100),GeneratedNumber Nvarchar(100),CLength Int,StartNumber bigint,Reset Nvarchar(40),Preview NvarChar(100),IsEditable Bit,IsEditableDisable Bit)  
 
 
 Declare @modulemasterId BigInt,  
   @generatedNumber Nvarchar(50),  
   @format Nvarchar(100),  
   @isEditable bit,  
   @LastDocNo Nvarchar(50),  
   @lastCreatedDate DateTime,  
   @counter int=0,  
   @AutoNumberType NvarChar(80),  
   @Isexists bit

  BEGIN TRY  
   Select @modulemasterId=m.Id from Common.ModuleMaster as m (NOLOCK) where Name=@CursorName and CompanyId=0  
   
   if(@CursorName ='Bean Cursor')
   BEGIN 
   SELECT @Isexists = CASE 
                      WHEN EXISTS (Select Id from Bean.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
                      THEN 1
                      ELSE 0
					  END
   END

   ---New Code
   else if(@CursorName ='HR Cursor')
   BEGIN 
   SELECT @Isexists = CASE 
                      WHEN EXISTS (Select Id from HR.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
                      THEN 1
                      ELSE 0
					  END
   END
   --END
   else
   BEGIN
   SELECT @Isexists = CASE 
                      WHEN EXISTS (Select Id from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
                      THEN 1
                      ELSE 0
					  END
   END


   --Select Id from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType

   IF(@Isexists = 1)  
   BEGIN--If AutoNumber is Exist  
   
   if(@CursorName ='Bean Cursor')
   BEGIN
	Insert Into @AutoTemp 
	Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview,IsEditable,IsEditableDisable 
	from Bean.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType  
   END
   ---NEW CODE
    Else if(@CursorName ='HR Cursor')
      BEGIN
	Insert Into @AutoTemp 
	Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview,IsEditable,IsEditableDisable 
	from HR.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType  
   END
   ----End
   else
   BEGIN
	Insert Into @AutoTemp 
	Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview,IsEditable,IsEditableDisable 
	from Common.AutoNumber (NOLOCK) where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType  
   END

    --If(@CursorName='Bean Cursor' and (@EntityType='Invoice')OR(@EntityType='Credit Note')OR(@EntityType='Debt Provision'))  
    Set @AutoNumberType=@EntityType;  
    If(@CursorName='Bean Cursor')  
    Begin--If cursor name Bean  
       
     If(@EntityType='Payroll Payment')  
      Begin  
       Set @EntityType='Payroll';  
      END  
      Else If(@EntityType='Payment')  
      Begin  
       Set @EntityType='General';  
      END  
      Else If(@EntityType='Recurring Journal')  
      Begin  
       Set @EntityType='Recurring';  
      End  
    End  

	---New Code
	If(@CursorName='HR Cursor')  
    Begin--If cursor name Bean  
       
     If(@EntityType='Employee')  
      Begin  
       Set @EntityType='Employee';  
      END  
     
    End  
	---End

     SET @isEditable=(select t.IsEditable from @AutoTemp as t)  
     IF(@isEditable=1)   
     BEGIN--If it is Editable  
        
		Set @LastDocNo = (select [dbo].[Common_GetLastDocNo](@CompanyId,@CursorName,@EntityType))  
		If(@LastDocNo Is Not Null)  
		BEGIN 
			IF(ISNUMERIC(Left(Reverse(@lastDocNo),1))=1)  
			BEGIN  
				Set @DocNo=(select dbo.GetNextSequenceNumber(@lastDocNo,@CompanyId,@EntityType))  
			END  
			
			Else  
			BEGIN  
				SET @DocNo= @lastdocno+ Cast(1 as varchar(5));  
				If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
				Begin  
					Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
				End  
			END  
		END--END of Invoice is Exists  
		Else  
		BEGIN  
			Set @DocNo=(Select a.Preview from @AutoTemp as a) 
		END  
     END--End of is Editable  
     ELSE  
     BEGIN--If it is Auto-Number  
		Set @LastDocNo= (select [dbo].[Common_GetLastDocNo](@CompanyId,@CursorName,@EntityType))  
		If(@LastDocNo is not null)  
		BEGIN--If Invoice is Exists  
       
		Select @format=a.Format from @AutoTemp as a  
		IF(@format Like '%{MM/YYYY}%')  
		BEGIN--If contains the Month Format  
       
			select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As      varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(t.GeneratedNumber)) + cast (t.GeneratedNumber as varchar) from  @AutoTemp as t  
			If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
			Begin--If exists   
				select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As      varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(t.GeneratedNumber+1)) + cast   (t.GeneratedNumber+1 as varchar) from @AutoTemp as t  
            
				If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
				Begin  
					Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
					If(@IsAdd=0)  
					Begin 
					
					 if(@CursorName ='Bean Cursor')
					    BEGIN
					       Update Bean.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
					    END
                     Else IF(@CursorName ='HR Cursor') ---New code HR Line
					   BEGIN
					       Update HR.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
					   END
					 else
					 BEGIN
						Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
					 END
					End  
					----New code HR
					--Else If(@IsAdd=0)  
					--Begin 
					
					-- if(@CursorName ='HR Cursor')
					-- BEGIN
					-- Update HR.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
					-- END

					-- else
					-- BEGIN
					--	Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
					-- END
					--End  

					--END CODE
			END  
			Else  
			Begin  
				If(@IsAdd=0)  
				Begin  
				 if(@CursorName ='Bean Cursor')
					 BEGIN
					 Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
					 END
                  Else If(@CursorName ='HR Cursor') --New Code Line HR
				     BEGIN
					    Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
					 END
					 else
					 BEGIN
					 Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
					 END
				End  
				---New Code HR
				--Else If(@IsAdd=0)  
			 --    	 Begin  
				--     if(@CursorName ='HR Cursor')
				--	 BEGIN
				--	 Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
				--	 END
				--	 else
				--	 BEGIN
				--	 Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t)     where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
				--	 END
				--End  
				---New code End
			End  
          End--End of If exists  
          Else  
          Begin  
           Set @DocNo=@DocNo;  
           --Update Common.AutoNumber SET GeneratedNumber=(Select t.StartNumber from @AutoTemp t)      where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId
			If(@IsAdd=0)  
			Begin 
			if(@CursorName ='Bean Cursor')
			   BEGIN
				  Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			   END
			Else If(@CursorName ='HR Cursor')---New Code Line HR
			  BEGIN
			     Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			  END
			else
			BEGIN
				Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			END
			---New code Start hr
			-- Else if(@CursorName ='HR Cursor')
			--   BEGIN
			--	Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			--    END
			--else
		 --   	BEGIN
			--	  Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			--   END
			---New code End
			End 
          End  
         --END--End of Month is same  
        --END-- End of doc no exist  
       END--End of Month format  
       ELSE--If not contains Month format   
       BEGIN  
        --IF(YEAR(@lastCreatedDate)<>YEAR(GETUTCDATE()))  
        --BEGIN--IF year is changed  
        -- select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(1)) + cast (t.StartNumber as varchar) from @AutoTemp as t  
        -- If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
        -- Begin  
        --  Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
        --  If(@IsAdd=0)  
        --  Begin  
        --   Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select t.CLength   from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType and       ModuleMasterId=@modulemasterId  
        --  End  
        -- END  
  
        --END--End of year changed  
        --ELSE  
        --BEGIN--IF year is same  
         select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(t.GeneratedNumber)) + cast (t.GeneratedNumber as varchar) from @AutoTemp as t  
         IF ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
         Begin-- If Exists  
          select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE())) + replicate('0', t.CLength - len    (t.GeneratedNumber+1)) + cast (t.GeneratedNumber+1 as varchar) from @AutoTemp as t  
          If ((Select [dbo].[Common_IfDocNoExistsOrNot] (@CompanyId,@CursorName,@EntityType,@DocNo))=1)  
           Begin  
            Set @DocNo=(select dbo.GetNextSequenceNumber(@DocNo,@CompanyId,@EntityType))  
            If(@IsAdd=0)  
            Begin
			

			if(@CursorName ='Bean Cursor')
			  BEGIN
                 Update Bean.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId
			  END
			Else If(@CursorName ='HR Cursor') --New Line code HR
			  BEGIN
			    Update HR.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId
			  END
			 else
			 BEGIN
			  Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
			 END

			 --New code HR
			     --if(@CursorName ='HR Cursor')
			     -- BEGIN
        --           Update HR.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId
			     -- END

			     --else
			     -- BEGIN
			     --  Update Common.AutoNumber Set GeneratedNumber=Reverse(SubString(REVERSE(@docNo),1,(select     t.CLength from @AutoTemp as t))) where CompanyId=@CompanyId and EntityType=@AutoNumberType     and ModuleMasterId=@modulemasterId  
			     -- END
			 --New code End

            End  
           END  
          Else  
          BEGIN  
           If(@IsAdd=0)  
           Begin  

		   	if(@CursorName ='Bean Cursor')
			BEGIN
				Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
			END
			IF(@CursorName ='HR Cursor')  --New code Line Add HR
			  BEGIN
			     Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
			  END
			else
			BEGIN
			Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
			END
			 ---New code HR
			  --	if(@CursorName ='HR Cursor')
			  -- BEGIN
			  --  	Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
			  -- END

			  --else
			  -- BEGIN
			  --   Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
			  -- END
			 ---New code End
           End  
          End  
         End--End Of If Exists  
         Else  
         Begin  
			Set @DocNo=@DocNo;  
          --Update Common.AutoNumber SET GeneratedNumber=(Select t.StartNumber from @AutoTemp t) where     CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
			If(@IsAdd=0)  
			Begin  
			 if(@CursorName ='Bean Cursor')
			    BEGIN
				   Update Bean.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
				END
             Else If(@CursorName ='HR Cursor') ---New Code Add HR
			    BEGIN
				 Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
				END
			else
				BEGIN
				Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
				END
				----New Code HR
				   -- if(@CursorName ='HR Cursor')
			    --    BEGIN
				   --  Update HR.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
				   --END
				   --else
				   -- BEGIN
				   --  Update Common.AutoNumber SET GeneratedNumber=(Select t.GeneratedNumber+1 from @AutoTemp t) where   CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId 
				   -- END
				----New code End
			End 
         End  
        --END--End of Year is Same  
       END--END of not contains Month format   
      END--End of Invoice Exists  
      ELSE  
      BEGIN--If Invoice not exists  
       Select @format=a.Format from @AutoTemp as a  
       IF(@format Like '%{MM/YYYY}%')  
       BEGIN--If contains month and year  
        select @DocNo=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(1)) + cast (1 as varchar) from @AutoTemp as t  
       END  
       ELSE  
       BEGIN  
        select @DocNo=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(1)) + cast (1 as varchar) from @AutoTemp as t  
       END  
      END--END of If Invoice not exists  
     END--End of Auto-Number  
    --END--End of If cursor name is Bean and Entity Type is Invoice   
      
   END--End of Auto-Number Exists  
  END TRY  
  BEGIN CATCH  
  END CATCH  
END
GO

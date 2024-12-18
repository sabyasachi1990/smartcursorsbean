USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TypeIdMigration]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 --Create   
CREATE Procedure [dbo].[TypeIdMigration]( @EngagementId uniqueidentifier,@CompanyId bigint)
AS Begin
    Declare @acmmId Uniqueidentifier;
    Declare @TypeId Uniqueidentifier;
    Declare @Heading Nvarchar(100);
    Declare @code Nvarchar(100);


    DECLARE @acmmOldId UNIQUEIDENTIFIER      
    If  Exists (Select * from audit.auditcompanymenumaster where companyid=@CompanyId and engagementid=@EngagementId)
    Begin
        
        DECLARE MenuSetUp CURSOR FOR SELECT Id,Heading,TypeId,Code FROM Audit.auditcompanymenumaster where companyid=1 and engagementid is null  and Engagementtype='Statutory Audit';
          OPEN  MenuSetUp       
             FETCH NEXT FROM MenuSetUp INTO  @acmmOldId,@Heading,@TypeId,@code
             WHILE (@@FETCH_STATUS=0)      
             BEGIN      
                
                set @TypeId=(select id from Audit.WPSetup where EngagementId=@EngagementId and ReferenceId =@TypeId)
                   
				Update audit.auditcompanymenumaster set typeid=@TypeId where Engagementid=@EngagementId and Engagementtype='Statutory Audit' and Heading=@Heading and code=@code

				 Print @code;Print @Heading;
         
                FETCH NEXT FROM MenuSetUp INTO   @acmmOldId,@Heading,@TypeId,@code
             END     
              
        CLOSE MenuSetUp      
        DEALLOCATE MenuSetUp 


        Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@EngagementId,'MenuSetupAndPermissionsInserted','Success',18) 
    End
    
End






GO

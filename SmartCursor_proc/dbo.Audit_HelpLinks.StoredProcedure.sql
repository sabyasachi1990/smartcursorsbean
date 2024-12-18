USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_HelpLinks]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Audit_HelpLinks](@PartnerCompanyId Bigint)
AS Begin
    Declare @Id Uniqueidentifier;
    Declare @TypeId Uniqueidentifier;
    Declare @ManualId Uniqueidentifier;
    Declare @TypeKey Nvarchar(1000);
    Declare @Type Nvarchar(1000);
    Declare @des Nvarchar(1000);
    If Not Exists (select * from [Common].[DocRepository] where companyid=@PartnerCompanyId and modulename='Audit Cursor' and filepath='HelpLinks')
    Begin        
        DECLARE HelpLink CURSOR FOR select Id,Type,TypeKey,Description from [Common].[DocRepository] where companyid=0 and modulename='Audit Cursor' and filepath='HelpLinks'
          OPEN  HelpLink       
             FETCH NEXT FROM HelpLink INTO  @Id,@Type,@TypeKey,@des
             WHILE (@@FETCH_STATUS=0)      
             BEGIN      
				If(@TypeKey='WP')
					Begin
					set @ManualId=(select  Id from  audit.auditmanual where companyid=@PartnerCompanyId and name in (@des))
					Set @TypeId=(select Id from audit.wpsetup where Code=@Type and CompanyId=@PartnerCompanyId and Engagementid is null and 
								Auditmanualid =@ManualId)
					End

				If(@TypeKey='PandL')
					Begin
					set @ManualId=(select  Id from  audit.auditmanual where companyid=@PartnerCompanyId and name in (@des))
					Set @TypeId= ( select Id from audit.planningandcompletionsetup where MenuName=@Type and CompanyId=@PartnerCompanyId and Engagementid is null and
								Auditmanualid =@ManualId)	
					End
 
		           If(@TypeId is not null)
				   Begin
				   If Not Exists (select * from  [Common].[DocRepository]  where TypeId=@TypeId)
				    Begin
						Insert into [Common].[DocRepository] (Id,CompanyId,TypeId,Type,TypeKey,ModuleName,FilePath,DisplayFileName,Description,FileSize,FileExt,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,NameofApprovalAuthority,TypeIntId,Status,ShortName,WordFile,MongoFilesId,GroupTypeId,ReferenceId,AzurePath,ScreenName,AzureFileName)
						select Newid(),@PartnerCompanyId,@TypeId,doc.Type,doc.TypeKey,doc.ModuleName,doc.FilePath,doc.DisplayFileName,doc.Description,doc.FileSize,doc.FileExt,doc.RecOrder,doc.UserCreated,doc.CreatedDate,doc.ModifiedBy,doc.ModifiedDate,doc.Version,doc.NameofApprovalAuthority,doc.TypeIntId,doc.Status,doc.ShortName,doc.WordFile,doc.MongoFilesId,doc.GroupTypeId,doc.ReferenceId,doc.AzurePath,doc.ScreenName,doc.AzureFileName
						from [Common].[DocRepository] as doc where id=@Id
						Print @Type;
					End
					End
				
             
                FETCH NEXT FROM HelpLink INTO @Id,@Type,@TypeKey,@des
             END     
              
        CLOSE HelpLink      
        DEALLOCATE HelpLink 
        
    End
    
End













GO

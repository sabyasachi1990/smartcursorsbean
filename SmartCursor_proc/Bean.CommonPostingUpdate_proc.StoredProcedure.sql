USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Bean].[CommonPostingUpdate_proc]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
CREATE PROCEDURE [Bean].[CommonPostingUpdate_proc] (                
@Id UNIQUEIDENTIFIER,      
@CompanyId BIGINT,      
@DocumentState nvarchar(100),      
@BalanceAmount money null,
@ModifiedBy nvarchar(400),
@ModifiedDate datetime2(7) null
 )                
AS                
BEGIN   
 BEGIN TRY                
  BEGIN TRAN                
	  UPDATE J SET J.DocumentState=@DocumentState,J.BalanceAmount=@BalanceAmount,J.ModifiedBy=@ModifiedBy,J.ModifiedDate=@ModifiedDate from Bean.Journal J (ROWLOCK)
	  where CompanyId=@CompanyId and DocumentId=@Id
  COMMIT TRAN                
 END TRY              
 BEGIN CATCH              
  SELECT ERROR_NUMBER() AS ErrorNumber              
   ,ERROR_SEVERITY() AS ErrorSeverity              
   ,ERROR_STATE() AS ErrorState              
   ,ERROR_PROCEDURE() AS ErrorProcedure              
   ,ERROR_LINE() AS ErrorLine              
   ,ERROR_MESSAGE() AS ErrorMessage;              
  ROLLBACK TRAN;              
 END CATCH;              
END
GO

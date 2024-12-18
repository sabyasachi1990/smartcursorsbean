USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteTempRecordFromOB_OBD_OBLD_proc]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
CREATE PROCEDURE [dbo].[DeleteTempRecordFromOB_OBD_OBLD_proc] (              
 @OBId Uniqueidentifier
 )              
AS              
BEGIN              
 BEGIN TRY              
  BEGIN TRAN              
	 
			IF EXISTS (Select 1 from Bean.OpeningBalance where Id=@OBId)
			BEGIN
				Delete OBDL from Bean.OpeningBalance OB with (nolock)
				inner join Bean.OpeningBalanceDetail OBD with (nolock)
				on OBD.OpeningBalanceId=OB.Id
				inner join Bean.OpeningBalanceDetailLineItem OBDL with (nolock)
				on OBDL.OpeningBalanceDetailId=OBD.Id
				where OB.Id=@OBId and OB.CompanyId=0


				Delete OBD from Bean.OpeningBalance OB with (nolock)
				inner join Bean.OpeningBalanceDetail OBD with (nolock)
				on OBD.OpeningBalanceId=OB.Id
				where OB.Id=@OBId and OB.CompanyId=0


				Delete OB from Bean.OpeningBalance OB with (nolock)
				where OB.Id=@OBId and OB.CompanyId=0
			END
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

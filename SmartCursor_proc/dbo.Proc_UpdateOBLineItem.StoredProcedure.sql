USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_UpdateOBLineItem]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Proc_UpdateOBLineItem] (@OBId uniqueidentifier, @DocumentId uniqueidentifier, @CompanyId BIGINT, @IsEqual bit)
AS BEGIN
	IF EXISTS(select * from Bean.OpeningBalance where Id=@OBId and CompanyId=@CompanyId )
	BEGIN
		IF(@IsEqual = 1)
			BEGIN
				UPDATE Bean.OpeningBalance SET IsEditable=1 where Id=@OBId and CompanyId=@CompanyId
				UPDATE Bean.OpeningBalanceDetailLineItem SET IsEditable=1 where Id=@DocumentId 
			END
		ELSE
			BEGIN
				UPDATE Bean.OpeningBalance SET IsEditable=0 where Id=@OBId and CompanyId=@CompanyId
				UPDATE Bean.OpeningBalanceDetailLineItem SET IsEditable=0 where Id=@DocumentId 

			END
	  END
 END
GO

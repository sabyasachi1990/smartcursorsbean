USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditAdjustments_DashBoard]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Proc_AuditAdjustments_DashBoard](@EngagementId Uniqueidentifier)
as begin 

declare @Adjustments table(Paje int,Prje int,Cje int,Unassigenedaccount int)  

declare @Paje int,@Prje int,@Cje int,@Unassigenedaccount int
Begin Transaction
BEGIN TRY

set @Paje=(select Count(*) from audit.Adjustment where EngagementID=@EngagementId and AdjustmentType ='Paje' and IsProposed=1)
set @Prje=(select Count(*) from audit.Adjustment where EngagementID=@EngagementId and AdjustmentType ='Prje' and IsProposed=1)
set @Cje=(select Count(*) from audit.Adjustment where EngagementID=@EngagementId and AdjustmentType ='Cje' and IsProposed=1)

Set @Unassigenedaccount=(Select count(*) from audit.TrialBalanceImport where EngagementId=@EngagementId and LeadSheetId ='00000000-0000-0000-0000-000000000000')


insert into @Adjustments values(@Paje,@Prje,@Cje,@Unassigenedaccount)
Select * from @Adjustments
Commit Transaction;
END TRY

BEGIN CATCH
	RollBack Transaction;
	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH
end

GO

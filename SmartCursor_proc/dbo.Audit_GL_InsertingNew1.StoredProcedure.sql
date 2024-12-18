USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_GL_InsertingNew1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE   Procedure [dbo].[Audit_GL_InsertingNew1] ( @EngagementId Uniqueidentifier, @CompanyId BigInt, @IsOverRide Int,@GlType Nvarchar(50))
AS
Begin 
      Declare @AccountName Nvarchar(1000)
	  Declare @Date Nvarchar(300) 
	  Declare @Type Nvarchar(max) 
	  Declare @SubType Nvarchar(max)
	  Declare @Entity Nvarchar(max) 
	  Declare @Description Nvarchar(max) 
	  Declare @Source Nvarchar(max) 
	  Declare @DocNo Nvarchar(max) 
	  Declare @Currency Nvarchar(200)
	  Declare @Amount Nvarchar(10)
	  Declare @Debit Nvarchar(50)
	  Declare @Credit Nvarchar(50)
	  Declare @Balance Nvarchar(50)
	  Declare @GLTpe Nvarchar(50)
	  Declare @TotalName Nvarchar(500)
	  Declare @Recorder  bigint
	  Declare @GeneralLedgerId Uniqueidentifier
	  Declare @Op Money
	  Declare @StartRec Int
	  Declare @EndRec Int
	  Declare @RecCount Int
	  Declare @EndRecord Int

	  --set ansi_warnings off


		CREATE TABLE #gltemp
		(
		AccountName varchar(5000) NULL,
		startNumber int,
		endNumber int
		)
		Insert into #gltemp
 	    select AccountName,Recorder, ROW_NUMBER() OVER (ORDER BY i.Recorder) as RecNumber from Import.Importgl as i where engagementid=@EngagementId and GlType=@GlType and  accountname is not null and accountname not like '%Total%' and accountname not like '%Sub Total:%' and Date is null order by recorder
	  
		
		
		
	IF @IsOverRide=1
		Begin

			Delete From Audit.GeneralLedgerDetail Where GeneralLedgerId In (Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType)
			Delete From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType

			Declare GLINSERT  cursor for select  AccountName,startNumber,endNumber from #gltemp
			Open GLINSERT  
			FETCH NEXT FROM   GLINSERT into @AccountName,@StartRec,@EndRec
			WHILE (@@FETCH_STATUS=0)
				BEGIN
				print @AccountName;
					Set @GeneralLedgerId=newid();
					print'Nikita'
					select @GeneralLedgerId,@EngagementId,@CompanyId,RTrim(LTrim(@AccountName)),
					Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else 0 End,
					igl.Recorder,'System',GetDate(),1,igl.GlType
					from Import.Importgl as igl where AccountName=@AccountName and EngagementId=@EngagementId and GlType=@GlType
					Insert into Audit.GeneralLedgerImport(Id,EngagementId,CompanyId,AccountName,OpeningBalance,RecOrder,UserCreated,CreatedDate,Status,GLType)
					select @GeneralLedgerId,@EngagementId,@CompanyId,RTrim(LTrim(@AccountName)),
					Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else 0 End,
					igl.Recorder,'System',GetDate(),1,igl.GlType
					from Import.Importgl as igl where AccountName=@AccountName and EngagementId=@EngagementId and GlType=@GlType

					set @EndRecord=(select startNumber-1 from #gltemp where endNumber=(@EndRec+1))
					set @EndRecord=CASE WHEN (@EndRecord IS not NULL) THEN @EndRecord ELSE (select MAX(Recorder) from Import.Importgl where EngagementId=@EngagementId and GLType=@GlType) END 
					print 'GeneralLedgerDetail'
					Insert Into Audit.GeneralLedgerDetail (Id,GeneralLedgerId,Description,GLDate,Debit,Credit,Balance,EntityType,
					RecOrder,DocNo,Currency,EntityName,EntitySubType)
					select newid(),@GeneralLedgerId,igl.[Description],
					Case When igl.[Date]='' Then Null Else CONVERT(datetime2(7),igl.[Date],103) End,
					Case When igl.Debit Is not Null And igl.Debit<>'' Then CAST(Replace(Replace(Replace(igl.Debit,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					Case When igl.Credit Is not Null And igl.Credit<>'' Then CAST(Replace(Replace(Replace(igl.Credit,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					igl.Type,igl.Recorder,igl.DocNo,igl.Currency,igl.Entity,igl.SubType
 
					from Import.Importgl as igl where  [Date] is not null AND  [Date] <> '' and Recorder Between (@StartRec+1) and @EndRecord and (debit is not null or credit is not null )

					print @StartRec+1;
					set @RecCount=(select startNumber-1 from #gltemp where endNumber=(@StartRec+1));

					print @RecCount;

					FETCH NEXT FROM   GLINSERT into @AccountName,@StartRec,@EndRec
				END
			CLOSE GLINSERT
			DEALLOCATE GLINSERT

		End
	Else
		Begin

			Declare GLINSERT  cursor for select  AccountName,startNumber,endNumber from #gltemp
			Open GLINSERT  
			FETCH NEXT FROM   GLINSERT into @AccountName,@StartRec,@EndRec
			WHILE (@@FETCH_STATUS=0)
				BEGIN
				print @AccountName;
					Set @GeneralLedgerId=newid();
					If Exists (Select Id From Audit.GeneralLedgerImport Where AccountName=RTrim(LTrim(@AccountName)) And EngagementId=@EngagementId And GLType=@GlType)
					Begin
						Delete From Audit.GeneralLedgerDetail Where GeneralLedgerId In (Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType And AccountName=RTrim(LTrim(@AccountName)))
						Set @GeneralLedgerId=(Select Id From Audit.GeneralLedgerImport Where EngagementId=@EngagementId and GLType=@GlType And AccountName=@AccountName);

						Update Audit.GeneralLedgerImport set OpeningBalance=(Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else 0 End)
						from Import.Importgl as igl where igl.AccountName=@AccountName and igl.EngagementId=@EngagementId and igl.GlType=@GlType
					End
					Else
					Begin
						Insert into Audit.GeneralLedgerImport(Id,EngagementId,CompanyId,AccountName,OpeningBalance,RecOrder,UserCreated,CreatedDate,Status,GLType)
						select @GeneralLedgerId,@EngagementId,@CompanyId,RTrim(LTrim(@AccountName)),
						Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else 0 End,
						igl.Recorder,'System',GetDate(),1,igl.GlType
						from Import.Importgl as igl where AccountName=@AccountName and EngagementId=@EngagementId and GlType=@GlType
					End
 
					set @EndRecord=(select startNumber-1 from #gltemp where endNumber=(@EndRec+1))
					set @EndRecord=CASE WHEN (@EndRecord IS not NULL) THEN @EndRecord ELSE (select MAX(Recorder) from Import.Importgl where EngagementId=@EngagementId and GLType=@GlType) END 

					Insert Into Audit.GeneralLedgerDetail (Id,GeneralLedgerId,Description,GLDate,Debit,Credit,Balance,EntityType,
					RecOrder,DocNo,Currency,EntityName,EntitySubType)
					select newid(),@GeneralLedgerId,igl.[Description],
					Case When igl.[Date]='' Then Null Else CONVERT(datetime2(7),igl.[Date],103) End,
					Case When igl.Debit Is not Null And igl.Debit<>'' Then CAST(Replace(Replace(Replace(igl.Debit,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					Case When igl.Credit Is not Null And igl.Credit<>'' Then CAST(Replace(Replace(Replace(igl.Credit,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					Case When igl.Balance Is not Null And igl.Balance<>'' Then CAST(Replace(Replace(Replace(igl.Balance,',',''),'(','-'),')','') As Decimal(17,2)) Else null End,
					igl.Type,igl.Recorder,igl.DocNo,igl.Currency,igl.Entity,igl.SubType
 
					from Import.Importgl as igl where  [Date] is not null AND  [Date] <> '' and Recorder Between (@StartRec+1) and @EndRecord and (debit is not null or credit is not null )

					print @StartRec+1;
					set @RecCount=(select startNumber-1 from #gltemp where endNumber=(@StartRec+1));

					print @RecCount;

					FETCH NEXT FROM   GLINSERT into @AccountName,@StartRec,@EndRec

				END
			CLOSE GLINSERT
			DEALLOCATE GLINSERT


		End

   print 'Coming to Update Closing Balance';
	
	Update  a set a.ClosingBalance=isnull(OpeningBalance+(select isnull(sum(debit),0)-isnull(sum(credit),0) from Audit.GeneralLedgerDetail 
	where GeneralLedgerId=( select Id from Audit.GeneralLedgerImport where accountname=a.accountname and  EngagementId=@EngagementId and gltype=@GlType)),0)
	from Audit.GeneralLedgerImport  as a where  a.EngagementId=@EngagementId and a.GlType=@GlType 
    
	Drop table #gltemp

	print 'temp table dropped';

	INSERT INTO AUDIT.ENGAGEMENTHISTORY(Id, EngagementId, SeedDataType, SeedDataStatus,Recorder,CreatedTime)  
	Values(NewId(),@EngagementId,'GL','GL Uploaded Success','9',Getdate())

End
GO

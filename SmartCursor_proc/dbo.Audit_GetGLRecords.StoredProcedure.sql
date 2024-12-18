USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_GetGLRecords]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 
 
 CREATE
--Alter
Procedure [dbo].[Audit_GetGLRecords](@engagementId uniqueidentifier,@fromdate Datetime,@todate Datetime,@type nvarchar(100),
                              @leadsheetId uniqueidentifier null,@categoryId Nvarchar(max) null, @accountId Nvarchar(max) null)
As Begin
Create table #Temp1 (catId uniqueidentifier null);Insert into #Temp1 select * from  STRING_SPLIT ( @categoryId , ',' );
Create table #Temp2 (accId uniqueidentifier null);Insert into #Temp2 select * from  STRING_SPLIT ( @accountId , ',' );

			If(@type = 'Both')
				Begin
				if((Select count(*) from #Temp1)=0 and (Select count(*) from #Temp2)=0)
					Begin
					Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
										 @fromdate <= GLD.GLDate and  GLD.GLDate  <= @todate 
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)>0)
					Begin
					Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
								(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) )
										And										  
										TB.Id in  (select accId from #Temp2)
										And
										 @fromdate <= GLD.GLDate and  GLD.GLDate  <= @todate 
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)=0)
					Begin
					Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
										(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) )
										And
										 @fromdate <= GLD.GLDate and  GLD.GLDate  <= @todate 
					End
				End		
			If(@type = 'Debit')
				Begin
				if((Select count(*) from #Temp1)=0 and (Select count(*) from #Temp2)=0)
					Begin
					Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
											from Audit.GeneralLedgerImport GLI Inner Join
											Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
											Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
											WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
											And
											  GLI.GlType='CY'
											And 
											  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
											And
											  @fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate 
											And 
											  (GLD.Debit is not null  and GLD.Debit !=0.00)
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)>0)
					Begin
						Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
											from Audit.GeneralLedgerImport GLI Inner Join
											Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
											Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
											WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
											And
											  GLI.GlType='CY'
											And 
											  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END											 
											And 
								(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) ) 
											And							
											TB.Id in  (select accId from #Temp2)
											And
											@fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate
											And
											(GLD.Debit is not null  and GLD.Debit !=0.00)
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)=0)
					Begin
						Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
											from Audit.GeneralLedgerImport GLI Inner Join
											Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
											Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
											WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
											And
											  GLI.GlType='CY'
											And 
											  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END											
											And 
											(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) )		
											And
										@fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate				And
											(GLD.Debit is not null  and GLD.Debit !=0.00)
					End
				End					  
			If(@type = 'Credit')
				Begin
				if((Select count(*) from #Temp1)=0 and (Select count(*) from #Temp2)=0)
					Begin
						Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
										  @fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate 
										And 
										  ( GLD.Credit is not null  and  GLD.Credit !=0.00)
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)>0)
					Begin
						Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
										  @fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate 
										And 
										(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) )
										And										  
										TB.Id in  (select accId from #Temp2)
										And
										( GLD.Credit is not null  and  GLD.Credit !=0.00)
					End
				if((Select count(*) from #Temp1)>0 and (Select count(*) from #Temp2)=0)
					Begin 
						Select  GLD.Id,GLI.AccountName,GLD.Debit,GLD.Credit,GLD.Gldate,GLD.Description,GLI.EngagementId,
							GLD.Currency,GLD.EntityName,GLD.DocNo,GLD.Recorder,GLD.EntityType,GLD.EntitySubType
										from Audit.GeneralLedgerImport GLI Inner Join
										Audit.GeneralLedgerDetail GLD on GLD.GeneralLedgerId=GLI.Id Inner Join
										Audit.TrialBalanceImport TB on TB.AccountName=GLI.AccountName and TB.Engagementid=GLI.Engagementid
										WHERE GLI.Engagementid=@engagementId and TB.Engagementid=@engagementId
										And
										  GLI.GlType='CY'
										And 
										  TB.LeadSheetid = CASE WHEN @leadsheetId = '00000000-0000-0000-0000-000000000000' THEN TB.LeadSheetid ELSE @leadsheetId END
										And
										  @fromdate <= Isnull(GLD.GLDate,Getdate()) and Isnull(GLD.GLDate,GetDate()) <= @todate 
										And 
										(Isnull(TB.CategoryId,'00000000-0000-0000-0000-000000000000') in   (select catId from #Temp1) )										
										And
										( GLD.Credit is not null  and  GLD.Credit !=0.00)
					End
				End	

	Drop table #Temp1;
	Drop table #Temp2
End












 

GO

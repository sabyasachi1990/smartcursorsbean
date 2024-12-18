USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_OpportunityCount]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_OpportunityCount](@CompanyId bigint, @UserName nvarchar(50),@Type nvarchar(20), @LeadId uniqueidentifier,@UserId uniqueidentifier)
as 
begin
	begin try
	    declare @OpportunityCount table (OppState nvarchar(20), OppCount int)
		declare @OppStateCount table (OppState nvarchar(20), OppCount int)
		declare @CompanyUserId bigint
		if(@UserName is not null)
		begin
			SET @CompanyUserId = (select Id from Common.CompanyUser where Username=@UserName and CompanyId=@CompanyId)
		end
		if (@Type = 'lead' OR @Type = 'account')
        begin
			--insert into @OpportunityCount values('All', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId=@LeadId and Status=1 and (istemp!=1 or istemp is null) ))     -- Opp All count		     
			----insert into @OpportunityCount values('ReOpening', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId=@LeadId and ReOpen > GETUTCDATE() and Status < 3 and isnull(QuoteNumber,' ' ) != 'ReOpened' and (Stage = 'Won' OR Stage ='Pending' OR Stage ='Complete' OR Stage ='Cancelled') and (Nature = 'Recurring (Without WF)' OR Nature = 'Recurring (With WF)' OR Nature = 'Recurring')))     -- Opp ReOpening count
	  --	    insert into @OpportunityCount values('ReOpening', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId=@LeadId and IsTemp=1))     -- Opp ReOpening count
	  --  	insert into @OpportunityCount values('Complete', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Complete' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Cancelled', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Cancelled' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Lost', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Lost' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Quoted', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Quoted' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Pending', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Pending' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Won', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Won' and AccountId=@LeadId and Status=1))
			--insert into @OpportunityCount values('Created', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Created' and AccountId=@LeadId and Status=1))

			------------Service Entites changes

			insert into @OppStateCount Select  opp.Stage,Count(opp.Id) from ClientCursor.Opportunity as opp join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and AccountId=@LeadId and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null) 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId
            group by opp.Stage

		    insert into @OpportunityCount values('Created', (select OppCount from @OppStateCount where  OppState ='Created' ))
		    insert into @OpportunityCount values('Quoted', (select OppCount from @OppStateCount where  OppState ='Quoted' ))
			insert into @OpportunityCount values('Pending', (select OppCount from @OppStateCount where  OppState ='Pending' ))
			insert into @OpportunityCount values('Won', (select OppCount from @OppStateCount where  OppState ='Won' ))
			insert into @OpportunityCount values('Lost', (select OppCount from @OppStateCount where  OppState ='Lost' ))
			insert into @OpportunityCount values('Complete', (select OppCount from @OppStateCount where  OppState ='Complete' ))
			insert into @OpportunityCount values('Cancelled', (select OppCount from @OppStateCount where  OppState ='Cancelled' ))

			insert into @OpportunityCount values('ReOpening', (Select  COUNT(*) from ClientCursor.Opportunity as opp 
			join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and AccountId=@LeadId and opp.Status=1 and  IsTemp=1 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId ))

			insert into @OpportunityCount values('All',(Select  count(*) from ClientCursor.Opportunity as opp join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and AccountId=@LeadId and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null) 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId))
        end
		else 
		begin
			if(@CompanyUserId is not null)
			begin
				--insert into @OpportunityCount values('All', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
				--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
				--where o.CompanyId=@CompanyId  and oi.companyUserId=@CompanyUserId and o.Status = 1 and (o.istemp!=1 or o.istemp is null)))     -- Opp All count	
				
			--insert into @OpportunityCount values('All',	(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and (istemp!=1 or istemp is null)
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('ReOpening', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.CompanyId = companyId and o.IsTemp=1))   -- Opp ReOpening Count

			--		   insert into @OpportunityCount values('ReOpening',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and istemp=1 
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Complete', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Complete'))     -- Opp Complete count

			--			insert into @OpportunityCount values('Complete',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Complete'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Cancelled', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Cancelled'))     -- Opp Cancelled count	

			--		insert into @OpportunityCount values('Cancelled',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Cancelled'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Lost', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Lost'))     -- Opp Lost count

			--				insert into @OpportunityCount values('Lost',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Lost'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


					
			--	--insert into @OpportunityCount values('Quoted', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Quoted'))     -- Opp Quoted count	

			--				insert into @OpportunityCount values('Quoted',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Quoted'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Pending', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Pending'))     -- Opp Pending count	

			--			insert into @OpportunityCount values('Pending',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Pending'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Won', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Won'))     -- Opp Won count	
								
			--	insert into @OpportunityCount values('Won',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Won'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


			--	--insert into @OpportunityCount values('Created', (select count(o.id) from ClientCursor.OpportunityIncharge Oi
			--	--left join ClientCursor.Opportunity o on oi.OpportunityId = o.Id
			--	--where o.CompanyId=@CompanyId and oi.companyUserId=@CompanyUserId and o.Status = 1 and o.Stage='Created'))     -- Opp Created count	

			--		insert into @OpportunityCount values('Created',(select COUNT(id) from ClientCursor.Opportunity where CompanyId=@CompanyId  and Status=1 and Stage='Created'
			--    and id in (select Distinct(OpportunityId) from ClientCursor.OpportunityIncharge where CompanyUserId=@CompanyUserId)))


				
				------------Service Entites changes

			insert into @OppStateCount Select  opp.Stage,Count(opp.Id) from ClientCursor.Opportunity as opp
			join ClientCursor.OpportunityIncharge as oppIn on opp.Id = oppIn.OpportunityId
			join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null)  and oppIn.CompanyUserId=@CompanyUserId
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId
            group by opp.Stage

		    insert into @OpportunityCount values('Created', (select OppCount from @OppStateCount where  OppState ='Created' ))
		    insert into @OpportunityCount values('Quoted', (select OppCount from @OppStateCount where  OppState ='Quoted' ))
			insert into @OpportunityCount values('Pending', (select OppCount from @OppStateCount where  OppState ='Pending' ))
			insert into @OpportunityCount values('Won', (select OppCount from @OppStateCount where  OppState ='Won' ))
			insert into @OpportunityCount values('Lost', (select OppCount from @OppStateCount where  OppState ='Lost' ))
			insert into @OpportunityCount values('Complete', (select OppCount from @OppStateCount where  OppState ='Complete' ))
			insert into @OpportunityCount values('Cancelled', (select OppCount from @OppStateCount where  OppState ='Cancelled' ))

			insert into @OpportunityCount values('ReOpening', (Select  COUNT(*) from ClientCursor.Opportunity as opp 
			join ClientCursor.OpportunityIncharge as oppIn on opp.Id = oppIn.OpportunityId
			join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and  IsTemp=1  and oppIn.CompanyUserId=@CompanyUserId
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId ))

			insert into @OpportunityCount values('All',(Select  count(*) from ClientCursor.Opportunity as opp 
			join ClientCursor.OpportunityIncharge as oppIn on opp.Id = oppIn.OpportunityId
			join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null) and oppIn.CompanyUserId=@CompanyUserId
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId))
			end
			else
			begin

				--insert into @OpportunityCount values('All', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and  Status=1 and (istemp!=1 or istemp is null)))     -- Opp All count		     

				----insert into @OpportunityCount values('ReOpening', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and  ReOpen > GETUTCDATE() and Status < 3 and ReOpen > GETUTCDATE() and isnull(QuoteNumber,' ' ) != 'ReOpened' and (Stage = 'Won' OR Stage ='Pending' OR Stage ='Complete' OR Stage ='Cancelled') and (Nature = 'Recurring (Without WF)' OR Nature = 'Recurring (With WF)' OR Nature = 'Recurring')))    -- Opp ReOpening count

				--insert into @OpportunityCount values('ReOpening', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and IsTemp=1))    -- Opp ReOpening count


	   -- 		insert into @OpportunityCount values('Complete', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Complete' and  Status=1))  -- Opp Complete Count

				--insert into @OpportunityCount values('Cancelled', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Cancelled' and  Status=1))  -- Opp Cancelled Count

				--insert into @OpportunityCount values('Lost', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Lost' and  Status=1))  -- Opp Lost Count

				--insert into @OpportunityCount values('Quoted', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Quoted' and  Status=1))  -- Opp Quoted Count

				--insert into @OpportunityCount values('Pending', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Pending' and  Status=1))  -- Opp Pending Count

				--insert into @OpportunityCount values('Won', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Won' and  Status=1))  -- Opp Won Count

				--insert into @OpportunityCount values('Created', (select COUNT(*) from ClientCursor.Opportunity where CompanyId=@CompanyId and Stage ='Created' and  Status=1))  -- Opp Created Count


				------------Service Entites changes

			insert into @OppStateCount Select  opp.Stage,Count(opp.Id) from ClientCursor.Opportunity as opp join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null) 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId
            group by opp.Stage

		    insert into @OpportunityCount values('Created', (select OppCount from @OppStateCount where  OppState ='Created' ))
		    insert into @OpportunityCount values('Quoted', (select OppCount from @OppStateCount where  OppState ='Quoted' ))
			insert into @OpportunityCount values('Pending', (select OppCount from @OppStateCount where  OppState ='Pending' ))
			insert into @OpportunityCount values('Won', (select OppCount from @OppStateCount where  OppState ='Won' ))
			insert into @OpportunityCount values('Lost', (select OppCount from @OppStateCount where  OppState ='Lost' ))
			insert into @OpportunityCount values('Complete', (select OppCount from @OppStateCount where  OppState ='Complete' ))
			insert into @OpportunityCount values('Cancelled', (select OppCount from @OppStateCount where  OppState ='Cancelled' ))

			insert into @OpportunityCount values('ReOpening', (Select  COUNT(*) from ClientCursor.Opportunity as opp 
			join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and  IsTemp=1 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId ))

			insert into @OpportunityCount values('All',(Select  count(*) from ClientCursor.Opportunity as opp join Common.CompanyUser as cu on opp.CompanyId = cu.CompanyId
            join Common.CompanyUserDetail as cud on cu.Id=cud.CompanyUserId join Common.Company as c on cud.ServiceEntityId = c.Id
            where opp.CompanyId=@CompanyId  and opp.Status=1 and (opp.istemp!=1 or opp.istemp is null) 
			and cu.UserId=@UserId and cud.ServiceEntityId=opp.ServiceCompanyId))

			end
		end
		select OppState ,isnull( OppCount,0) as OppCount from @OpportunityCount
	end try
	begin catch
		print ('Failed..!')
	end catch
end
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_PendingOpportunity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Procedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_PendingOpportunity]
@FromDate date,
@ToDate date,
@CompanyId Int,
@EmployeeId UniqueIdentifier 
As
Begin
--Declare @OutPut Table 
Declare @OutPut Table (EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),
                       CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000),STARTDATE DATE,
					   ENDDATE DATE,TOATLHOURS MONEY, ISOVERRUNHOURS MONEY,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000), SCHEDULETYPEID UNIQUEIDENTIFIER NULL, SCHEDULETYPE NVARCHAR(100), IsActualHrs bit)   -- ScheduleTypeid means Calender / LeaveApplication Id - Added by SSK
--Declare Cursor Variables
Declare @W_FromDate date,
        @W_ToDate date,
		@CaseNumber varchar(Max)
Declare @Week_table table (W_FromDate Date,W_ToDate date) 
Insert into @Week_table SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)
--Select * from @Week_table
--If @CompanyId=1
Begin
--Declare Cursor1 for weekdates 
Declare WeekTblCsr1 Cursor For Select * From @Week_table
--Open Cursor 1
Open WeekTblCsr1;
--Fetch Data from Cursor1
Fetch next from WeekTblCsr1 into @W_FromDate,@W_ToDate
While @@FETCH_STATUS=0 --Loop Begin For Cursor1
Begin
     --Declare Cursor 2 For Case Numbers
     Declare CaseNumCsr1 Cursor For 


	 Select distinct CG.CaseNumber 
	 From Common.TimeLogItem As TLI
          Inner join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
		  Inner Join ClientCursor.Opportunity As Opp On Opp.Id=CG.OpportunityId
		 -- Inner Join Common.TimeLogItemDetail As TLID on TLID.TimeLogItemId=TLI.Id
          Inner Join Common.TimeLog As TL on TL.TimeLogItemId=TLI.Id          
          Inner join Common.TimeLogDetail As TLD on TLD.MasterId=TL.Id
     where Tl.CompanyId=@CompanyId And TL.EmployeeId= @EmployeeId           
	       And (Duration <>'00:00:00.0000000')-- and Duration <> null)
	       And Date between @W_FromDate And @W_ToDate

    --Open Cursor 2
	 Open CaseNumCsr1;
	 --Fetch data into Cursor2
	 Fetch Next From CaseNumCsr1 Into @CaseNumber
	 While @@FETCH_STATUS=0 --Loop Begin For Cursor2
	 Begin
	 Insert Into @OutPut 
	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,Fromdate,
	        Todate,cast(TotalHours As money) As TotalHours, 0 AS ISOVERRUNHOURS,CaseId,PhotoURL,NULL,NULL, 1  -- NULL ScheduleTypeId Purpose
	 From
	 (
	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,@W_FromDate As Fromdate,
	        @W_ToDate As Todate,CAST((TotalMinutes)/60 AS varchar(6)) + '.' + CAST((TotalMinutes)%60 As varchar(20)) As TotalHours,
			CaseId,PhotoURL 
	 From
	      ( 
		  Select E.FirstName As EmployeeName,
                 TL.EmployeeId,E.EmployeeId As EmployeeNumber,C.Name As ClientName,
                 CG.CaseNumber,CG.Name As CaseName,--@W_FromDate As Fromdate,@W_ToDate As Todate,
				 Sum(datepart(hh,duration)*60+datepart(MI,duration)) As TotalMinutes,
				 --Convert(decimal(10,2),datepart(hh,duration))+
	             --Convert(decimal(10,2),('0.'+Substring(Convert(varchar(max),duration),Charindex(':',Duration)+1,2))) As TotalHours,
				 CG.Id As CaseId,MR.Small As PhotoURL
          From Common.TimeLogItem As TLI
               Inner Join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
			   Inner Join ClientCursor.Opportunity As Opp On Opp.Id=CG.OpportunityId
              -- Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
               Inner Join Common.Employee As E on E.Id=TL.EmployeeId
               Inner Join WorkFlow.Client As C On C.Id=CG.ClientId 
               Left Join Common.MediaRepository As MR on MR.Id=E.PhotoId
		  Where (Duration<>'00:00:00.0000000') AND    -- AND Duration<> null added by SSK
		        CG.CaseNumber=@CaseNumber And
		        CG.CompanyId=@CompanyId And 
				Opp.Stage='Pending' And
				--TLI.StartDate is null And 
				--TLI.EndDate is null And 
				TLD.Date Between @W_FromDate And @W_ToDate And 
				TL.EmployeeId=@EmployeeId
				--And TLD.Date Between @W_FromDate And @W_ToDate
          Group by E.FirstName ,CG.Name,
                   TL.EmployeeId,E.EmployeeId,C.Name,CG.Id,
                   CG.CaseNumber,MR.Small
          ) As A
      ) As B
     --fetch data from cursor 2
	 Fetch Next From CaseNumCsr1 Into @CaseNumber
	 End --End Loop For Cursor2
	 Close CaseNumCsr1 --Close Cursor2
	 Deallocate CaseNumCsr1 --Deallocate Cursor2
  --Fetch Data From Cursor1
  Fetch Next From WeekTblCsr1 into @W_FromDate,@W_ToDate  
  End --End Cursor1 Loop
  Close WeekTblCsr1; --Close Cursor1
  Deallocate WeekTblCsr1 --Deallocate cursor

 -- select * from @OutPut  --**************

  END

--Else 

--Begin
----Declare Cursor1 for weekdates 
--Declare WeekTblCsr Cursor For Select * From @Week_table
----Open Cursor 1
--Open WeekTblCsr;
----Fetch Data from Cursor1
--Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
--While @@FETCH_STATUS=0 --Loop Begin For Cursor1
--Begin
--     --Declare Cursor 2 For Case Numbers
--     Declare CaseNumCsr Cursor For 
--		 Select Distinct CG.CaseNumber
--		 From   Common.TimeLogItem As TLI
--				Inner Join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
--				Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
--				Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
--				Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id    -- AND Duration<> null added by SSK
--		 Where (Duration<>'00:00:00.0000000') And CG.CompanyId=@CompanyId --And TLI.StartDate is null And TLI.EndDate is null--and CG.FromDate is null And CG.ToDate is null
--			   And TLD.Date Between @W_FromDate And @W_ToDate And Tlid.EmployeeId=@EmployeeId

--	 --Open Cursor 2
--	 Open CaseNumCsr;
--	 --Fetch data into Cursor2
--	 Fetch Next From CaseNumCsr Into @CaseNumber
--	 While @@FETCH_STATUS=0 --Loop Begin For Cursor2
--	 Begin
--	 Insert Into @OutPut 
--	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,Fromdate,
--	        Todate,cast(TotalHours As money) As TotalHours,0 AS ISOVERRUNHOURS,CaseId,PhotoURL,NULL,NULL, 1  -- NULL ScheduleTypeId Purpose
--	 From
--	 (
--	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,@W_FromDate As Fromdate,
--	        @W_ToDate As Todate,CAST((TotalMinutes)/60 AS varchar(6)) + '.' + CAST((TotalMinutes)%60 As varchar(20)) As TotalHours,
--			CaseId,PhotoURL 
--	 From
--	      ( 
--		  Select E.FirstName As EmployeeName,
--                 TLID.EmployeeId,E.EmployeeId As EmployeeNumber,C.Name As ClientName,
--                 CG.CaseNumber,CG.Name As CaseName,--@W_FromDate As Fromdate,@W_ToDate As Todate,
--				 Sum(datepart(hh,duration)*60+datepart(MI,duration)) As TotalMinutes,
--				 --Convert(decimal(10,2),datepart(hh,duration))+
--	             --Convert(decimal(10,2),('0.'+Substring(Convert(varchar(max),duration),Charindex(':',Duration)+1,2))) As TotalHours,
--				 CG.Id As CaseId,MR.Small As PhotoURL
--          From Common.TimeLogItem As TLI
--               Inner Join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
--               Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
--               Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
--               Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
--               Inner Join Common.Employee As E on E.Id=TLID.EmployeeId
--               Inner Join WorkFlow.Client As C On C.Id=CG.ClientId 
--               Left Join Common.MediaRepository As MR on MR.Id=E.PhotoId
--		  Where (Duration<>'00:00:00.0000000') AND   -- AND Duration<> null added by SSK
--		        CG.CaseNumber=@CaseNumber And
--		        CG.CompanyId=@CompanyId And 
--				--TLI.StartDate is null And TLI.EndDate is null And 
--				TLD.Date Between @W_FromDate And @W_ToDate And 
--				Tlid.EmployeeId=@EmployeeId
--				--And TLD.Date Between @W_FromDate And @W_ToDate
--          Group by E.FirstName ,CG.Name,--@W_FromDate,@W_ToDate,
--                   TLID.EmployeeId,E.EmployeeId,C.Name,CG.Id,
--                   CG.CaseNumber,MR.Small
--          ) As A
--      ) As B
--     --fetch data from cursor 2
--	 Fetch Next From CaseNumCsr Into @CaseNumber
--	 End --End Loop For Cursor2
--	 Close CaseNumCsr --Close Cursor2
--	 Deallocate CaseNumCsr --Deallocate Cursor2
--  --Fetch Data From Cursor1
--  Fetch Next From WeekTblCsr into @W_FromDate,@W_ToDate  
--  End --End Cursor1 Loop
--  Close WeekTblCsr; --Close Cursor1
--  Deallocate WeekTblCsr --Deallocate cursor

--    --select * from @OutPut  --**************

--  End

  --// For All Employees ex:General,Leaves
--  Begin
----Declare Cursor1 for weekdates 
--Declare WeekTblCsr Cursor For Select * From @Week_table
----Open Cursor 1
--Open WeekTblCsr;
----Fetch Data from Cursor1
--Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
--While @@FETCH_STATUS=0 --Loop Begin For Cursor1
  
--	 Begin
--	 Insert Into @OutPut
--	 Select EmployeeName, EmployeeId, EmployeeNumber, ClientName, CaseNumber, CaseName, FromDate, ToDate,
--	        cast(TotalHours As money) As TotalHours, '0' As ISOVERRUNHOURS, SystemId, PhotoURL , SystemId  AS SCHEDULETYPEID, SystemType AS SCHEDULETYPE, 1
--	 From 
--	 (
--	 Select EmployeeName,EmployeeId,EmployeeNumber,' ' As ClientName,CaseNumber, CaseName, SystemId,@W_FromDate As FromDate,@W_ToDate As ToDate,
--			CAST((TotalMinutes)/60 AS varchar(6)) + '.' + CAST((TotalMinutes)%60 As varchar(20)) As TotalHours,PhotoURL, SystemId  AS SCHEDULETYPEID, SystemType
--	 From
--	 (
--	  Select Emp.FirstName As EmployeeName,EMP.EmployeeId As EmployeeNumber,TLID.EmployeeId As EmployeeId,
--			 SystemType As CaseNumber,SystemType As CaseName,@W_FromDate As FromDate,@W_ToDate As Todate,SystemId,
--			 Sum(datepart(hh,duration)*60+datepart(MI,duration)) As TotalMinutes,MR.Small As PhotoURL, SystemId AS SCHEDULETYPEID, SystemType
--	  From Common.TimeLogItem As TLI
--		  Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
--		  Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
--		  Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
--          Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
--		  Left Join Common.MediaRepository As MR on MR.Id=EMP.PhotoId
--	  Where (Duration<>'00:00:00.0000000')       -- AND Duration<> null added by SSK
--			And TLID.EmployeeId=@EmployeeId
--			And TLI.CompanyId=@CompanyId
--			And TLD.Date Between @W_FromDate And @W_ToDate
--	  Group By Emp.FirstName,EMP.EmployeeId,TLID.EmployeeId,SystemType,MR.Small,SystemId, SystemType 
--	  ) As A
--	  ) As B
	
--     --fetch data from cursor 1
--	Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
--	 End --End Loop For Cursor1

--	 Close WeekTblCsr --Close Cursor1
--	 Deallocate WeekTblCsr --Deallocate Cursor1

--	  -- select * from @OutPut  --**************


--  End


  --==============================================================================
  -- // for ALL Emps TimeLogDetail Hrs  -- Time Log Item Hrs [ssk added]

  Begin
--Declare Cursor1 for weekdates 
Declare WeekTblCsr Cursor For Select * From @Week_table
--Open Cursor 1
Open WeekTblCsr;
--Fetch Data from Cursor1
Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
While @@FETCH_STATUS=0 --Loop Begin For Cursor1
  
	 Begin
	 Insert Into @OutPut
	 Select EmployeeName, EmployeeId, EmployeeNumber, ClientName, CaseNumber, CaseName, FromDate, ToDate,
	        cast(TotalHours As money) As TotalHours, '0' As ISOVERRUNHOURS, SystemId, PhotoURL , SystemId  AS SCHEDULETYPEID, SystemType AS SCHEDULETYPE, 1
	 From 
	 ( -- (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS
	 Select EmployeeName,EmployeeId,EmployeeNumber, ClientName,CaseNumber, ' ' AS CaseName, SystemId,@W_FromDate As FromDate,@W_ToDate As ToDate,
			--CAST((TotalMinutes)/60 AS varchar(6)) + '.' + CAST((TotalMinutes)%60 As varchar(20)) As TotalHours,
			(TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TotalHours,
			PhotoURL, SystemId  AS SCHEDULETYPEID, SystemType
	 From
	 (
		select Emp.FirstName As EmployeeName,Emp.EmployeeId As EmployeeNumber,TL.EmployeeId As EmployeeId, TLI.Type+'('+TLI.SubType+')' As CaseNumber, TLI.Type+'('+TLI.SubType+')' As ClientName, @W_FromDate As FromDate,@W_ToDate As Todate,SystemId, Sum(datepart(hh,Duration)*60+datepart(MI,Duration)) As TotalMinutes,MR.Small As PhotoURL, TLI.Id AS SCHEDULETYPEID, 'Time Log Item' as SystemType From Common.TimeLog TL 
		join Common.TimeLogDetail TLD on TL.Id = TLD.MasterId
		join Common.TimeLogItem TLI on TLI.Id = TL.TimeLogItemId
		join Common.Employee Emp on emp.Id = TL.EmployeeId
		Left Join Common.MediaRepository As MR on MR.Id=EMP.PhotoId
		where TL.EmployeeId=@EmployeeId 
		and TLD.Duration <> '00:00:00.0000000' And TLD.Date Between @W_FromDate And @W_ToDate
		 Group By Emp.FirstName,EMP.EmployeeId,TL.EmployeeId,SystemType,MR.Small,SystemId, SystemType , TLI.Type, TLI.SubType, TLI.Id

	  ) As A where (A.SystemId is null and A.SystemType='Time Log Item') --OR ((A.SystemId is null and A.SystemType='Time Log Item'))
	  ) As B
	
     --fetch data from cursor 1
	Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
	 End --End Loop For Cursor1

	 Close WeekTblCsr --Close Cursor1
	 Deallocate WeekTblCsr --Deallocate Cursor1

	  -- select * from @OutPut  --**************

  End

 Select EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER ,
        CLIENTNAME,CASENUMBER ,CASENAME ,STARTDATE ,
		 ENDDATE, TOATLHOURS ,00.00 as ISOVERRUNHOURS ,CASEID ,PHOTOURL,SCHEDULETYPEID, SCHEDULETYPE , 1 as IsActualHrs
 From @OutPut Where CASEID <>'00000000-0000-0000-0000-000000000000'
  ORDER BY CASENUMBER

End
GO

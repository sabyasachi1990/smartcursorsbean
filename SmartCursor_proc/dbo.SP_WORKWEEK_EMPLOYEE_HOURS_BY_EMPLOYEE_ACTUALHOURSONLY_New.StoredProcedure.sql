USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  Procedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_New]
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
		 -- Inner Join Common.TimeLogItemDetail As TLID on TLID.TimeLogItemId=TLI.Id
          Inner Join Common.TimeLog As TL on TL.TimeLogItemId=TLI.Id          
          Inner join Common.TimeLogDetail As TLD on TLD.MasterId=TL.Id
     where Tl.CompanyId=@CompanyId And TL.EmployeeId= @EmployeeId           
	       And (Duration <>'00:00:00.0000000')-- and Duration <> null)
	       And Date between @W_FromDate And @W_ToDate
    --Open Cursor 2
	 Open CaseNumCsr1
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
              -- Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
               Inner Join Common.Employee As E on E.Id=TL.EmployeeId
               Inner Join WorkFlow.Client As C On C.Id=CG.ClientId 
               Left Join Common.MediaRepository As MR on MR.Id=E.PhotoId
		  Where (Duration<>'00:00:00.0000000') AND    -- AND Duration<> null added by SSK
		        CG.CaseNumber=@CaseNumber And
		        CG.CompanyId=@CompanyId And 
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

 select * from @OutPut  --**************

  END

end














GO

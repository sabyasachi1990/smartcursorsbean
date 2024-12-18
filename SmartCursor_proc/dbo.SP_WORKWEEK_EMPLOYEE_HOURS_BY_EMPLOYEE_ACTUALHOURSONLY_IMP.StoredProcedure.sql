USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_IMP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY @FromDate='2018-05-27',@ToDate='2018-06-30',@CompanyId=1316,@EmployeeId='c425ff82-1f48-4c2f-99b1-24de566b5deb'

Create Procedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY_IMP]
@FromDate date,
@ToDate date,
@CompanyId Int,
@EmployeeId UniqueIdentifier 
As
Begin
--Declare @OutPut Table 
Declare @OutPut Table (EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),
                       CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000),STARTDATE DATE,
					   ENDDATE DATE,TOATLHOURS MONEY,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000))
--Declare Cursor Variables
Declare @W_FromDate date,
        @W_ToDate date,
		@CaseNumber varchar(Max)
Declare @Week_table table (W_FromDate Date,W_ToDate date) 
Insert into @Week_table SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)
--Select * from @Week_table
--Declare Cursor1 for weekdates 
Declare WeekTblCsr Cursor For Select * From @Week_table
--Open Cursor 1
Open WeekTblCsr;
--Fetch Data from Cursor1
Fetch next from WeekTblCsr into @W_FromDate,@W_ToDate
While @@FETCH_STATUS=0 --Loop Begin For Cursor1
Begin
     --Declare Cursor 2 For Case Numbers
     Declare CaseNumCsr Cursor For 
     Select Distinct CG.CaseNumber
     From   Common.TimeLogItem As TLI
            Inner Join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
			Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
			Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
			Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
	 Where Duration<>'00:00:00.0000000' And CG.CompanyId=@CompanyId And TLI.StartDate is null And TLI.EndDate is null--and CG.FromDate is null And CG.ToDate is null
		   And TLD.Date Between @W_FromDate And @W_ToDate And Tlid.EmployeeId=@EmployeeId

	 --Open Cursor 2
	 Open CaseNumCsr;
	 --Fetch data into Cursor2
	 Fetch Next From CaseNumCsr Into @CaseNumber
	 While @@FETCH_STATUS=0 --Loop Begin For Cursor2
	 Begin
	 Insert Into @OutPut 
	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,Fromdate,
	        Todate,cast(TotalHours As money) As TotalHours,CaseId,PhotoURL
	 From
	 (
	 Select EmployeeName,EmployeeId,EmployeeNumber,ClientName,CaseNumber,CaseName,@W_FromDate As Fromdate,
	        @W_ToDate As Todate,CAST((TotalMinutes)/60 AS varchar(6)) + '.' + CAST((TotalMinutes)%60 As varchar(20)) As TotalHours,
			CaseId,PhotoURL 
	 From
	      ( 
		  Select E.FirstName As EmployeeName,
                 TLID.EmployeeId,E.EmployeeId As EmployeeNumber,C.Name As ClientName,
                 CG.CaseNumber,CG.Name As CaseName,--@W_FromDate As Fromdate,@W_ToDate As Todate,
				 Sum(datepart(hh,duration)*60+datepart(MI,duration)) As TotalMinutes,
				 --Convert(decimal(10,2),datepart(hh,duration))+
	             --Convert(decimal(10,2),('0.'+Substring(Convert(varchar(max),duration),Charindex(':',Duration)+1,2))) As TotalHours,
				 CG.Id As CaseId,MR.Small As PhotoURL
          From Common.TimeLogItem As TLI
               Inner Join WorkFlow.CaseGroup As CG on CG.Id=TLI.SystemId
               Inner Join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLog As TL On TL.TimeLogItemId=TLI.Id
               Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
               Inner Join Common.Employee As E on E.Id=TLID.EmployeeId
               Inner Join WorkFlow.Client As C On C.Id=CG.ClientId 
               Left Join Common.MediaRepository As MR on MR.Id=E.PhotoId
		  Where Duration<>'00:00:00.0000000' And 
		        CG.CaseNumber=@CaseNumber And
		        CG.CompanyId=@CompanyId And 
				TLI.StartDate is null And 
				TLI.EndDate is null And 
				TLD.Date Between @W_FromDate And @W_ToDate And 
				Tlid.EmployeeId=@EmployeeId
				--And TLD.Date Between @W_FromDate And @W_ToDate
          Group by E.FirstName ,CG.Name,--@W_FromDate,@W_ToDate,
                   TLID.EmployeeId,E.EmployeeId,C.Name,CG.Id,
                   CG.CaseNumber,MR.Small
          ) As A
      ) As B
     --fetch data from cursor 2
	 Fetch Next From CaseNumCsr Into @CaseNumber
	 End --End Loop For Cursor2
	 Close CaseNumCsr --Close Cursor2
	 Deallocate CaseNumCsr --Deallocate Cursor2
  --Fetch Data From Cursor1
  Fetch Next From WeekTblCsr into @W_FromDate,@W_ToDate  
  End --End Cursor1 Loop
  Close WeekTblCsr; --Close Cursor1
  Deallocate WeekTblCsr --Deallocate cursor

 Select EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER ,
        CLIENTNAME,CASENUMBER ,CASENAME ,STARTDATE ,
		 ENDDATE, 00.00 TOATLHOURS ,CASEID ,PHOTOURL 
 From @OutPut
  ORDER BY CASENUMBER

End                
GO

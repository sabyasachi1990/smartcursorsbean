USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_WorkProgram_StatisticsPBI]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Audit_WorkProgram_StatisticsPBI]
AS
BEGIN	
	
	-- Exec [dbo].[Audit_WorkProgram_StatisticsPBI]


	
DECLARE @TABLE1 TABLE 
  ([Sum     Credit] DOUBLE PRECISION,[Count    Credit] DOUBLE PRECISION,[Max     Credit] DOUBLE PRECISION,
  [Min     Credit] DOUBLE PRECISION,[StdDev  Credit] DOUBLE PRECISION,[Variance Credit] DOUBLE PRECISION,
  [Range    Credit] DOUBLE PRECISION,[StdError Credit] DOUBLE PRECISION,[Mode    Credit] DOUBLE PRECISION,
  [Sum     Debit] DOUBLE PRECISION,[Count    Debit] DOUBLE PRECISION,[Max     Debit] DOUBLE PRECISION,
  [Min     Debit] DOUBLE PRECISION,
  [StdDev  Debit] DOUBLE PRECISION,[Variance Debit] DOUBLE PRECISION,
  [Range    Debit] DOUBLE PRECISION,[StdError Debit] DOUBLE PRECISION,[Mode    Debit] DOUBLE PRECISION,
  
  [Sum     PYCredit] DOUBLE PRECISION,[Count    PYCredit] DOUBLE PRECISION,[Max     PYCredit] DOUBLE PRECISION,
  [Min     PYCredit] DOUBLE PRECISION,[StdDev  PYCredit] DOUBLE PRECISION,[Variance PYCredit] DOUBLE PRECISION,
  [Range    PYCredit] DOUBLE PRECISION,[StdError PYCredit] DOUBLE PRECISION,[Mode    PYCredit] DOUBLE PRECISION,
  [Sum     PYDebit] DOUBLE PRECISION,[Count    PYDebit] DOUBLE PRECISION,[Max     PYDebit] DOUBLE PRECISION,
  [Min     PYDebit] DOUBLE PRECISION,
  [StdDev  PYDebit] DOUBLE PRECISION,[Variance PYDebit] DOUBLE PRECISION,
  [Range    PYDebit] DOUBLE PRECISION,[StdError PYDebit] DOUBLE PRECISION,[Mode    PYDebit] DOUBLE PRECISION
  
  
  )

  Insert into @TABLE1
select sum as [Sum     Credit],[Count] as [Count    Credit],Max as [Max     Credit],Min as [Min     Credit],
[Standrad Deviation] as [StdDev  Credit],[Sample Variance] as [Variance Credit],[Range1] [Range    Credit],
[Standard Error] as [StdError Credit],Mode as [Mode    Credit],

SUM1 as [Sum     Debit],[Count1] as [Count    Debit],Max1 as [Max     Debit],Min1 as [Min     Debit],
[Standrad Deviation] as [StdDev  Debit],
[Sample Variance1] as [Variance Debit],Range1 as [Range    Debit],
[Standard Error1] as [StdError Debit],Mode1 as 'Mode    Debit',

sum11 as [Sum     PYCredit],[Count11] as [Count    PYCredit],Max11 as [Max     PYCredit],Min11 as [Min     PYCredit],
[Standrad Deviation11] as [StdDev  PYCredit],[Sample Variance11] as [Variance PYCredit11],[Range11] [Range    PYCredit],
[Standard Error11] as [StdError PYCredit],Mode2 as [Mode    PYCredit],

SUM22 as [Sum     PYDebit],[Count22] as [Count    PYDebit],Max22 as [Max     PYDebit],Min22 as [Min     PYDebit],
[Standrad Deviation22] as [StdDev  PYDebit],
[Sample Variance22] as [Variance PYDebit],Range22 as [Range    PYDebit],
[Standard Error22] as [StdError PYDebit],Mode3 as 'Mode    Debit'



from 
(
SELECT Sum1 AS 'SUM',Count1 AS 'Count',SK.Max1 'Max',SK.Min1 'Min',
SK.[Std Dev1] 'Standrad Deviation',SK.Variance1 'Sample Variance',SK.Range1 'Range',
SK.[STD Error1] AS 'Standard Error',SK.Mode AS 'Mode'--,CAST(NULL AS INTEGER) AS

,SK.Sum2 AS 'SUM1',SK.Count2 AS 'Count1',SK.Max2 'Max1',SK.Min2 AS 'Min1',
SK.[Std Dev2] AS 'Standrad Deviation1',SK.Variance2 'Sample Variance1',SK.Range2 'Range1',
SK.[STD Error2] AS 'Standard Error1',SK.Mode1 AS 'Mode1',

Sum11 AS 'SUM11',Count11 AS 'Count11',SK.Max11 'Max11',SK.Min11 'Min11',
SK.[Std Dev11] 'Standrad Deviation11',SK.Variance11 'Sample Variance11',SK.Range11 'Range11',
SK.[STD Error11] AS 'Standard Error11',SK.Mode AS 'Mode2'--,CAST(NULL AS INTEGER) AS

,SK.Sum22 AS 'SUM22',SK.Count22 AS 'Count22',SK.Max22 'Max22',SK.Min22 AS 'Min22',
SK.[Std Dev22] AS 'Standrad Deviation22',SK.Variance22 'Sample Variance22',SK.Range22 'Range22',
SK.[STD Error22] AS 'Standard Error22',SK.Mode1 AS 'Mode3'

FROM (

SELECT SUM(ISNULL(Cydebit,0)) 'Sum1',COUNT(ISNULL(Cydebit,0)) 'Count1',MAX(ISNULL(Cydebit,0)) 'Max1',NULL AS Mode
,MIN(Cydebit) 'Min1',AVG(Cydebit) 'Mean1',
 STDEV(Cydebit) 'Std Dev1',VAR(Cydebit) 'Variance1', (MAX(Cydebit) -MIN(Cydebit)) as Range1,
 ISNULL(STDEV(Cydebit)/SQRT(Count(Cydebit)),0) as 'STD Error1',

SUM(ISNULL(Cycredit,0)) 'Sum2',COUNT(ISNULL(Cycredit,0)) 'Count2',MAX(ISNULL(Cycredit,0)) 'Max2',NULL AS Mode1
,MIN(Cycredit) 'Min2',AVG(Cycredit) 'Mean2',
 STDEV(Cycredit) 'Std Dev2',VAR(Cycredit) 'Variance2', (MAX(Cycredit) -MIN(Cycredit)) as Range2,
 ISNULL(STDEV(Cycredit)/SQRT(Count(Cycredit)),0) as 'STD Error2'

 ,SUM(ISNULL(BH.Pydebit,0)) 'Sum11',COUNT(ISNULL(Pydebit,0)) 'Count11',MAX(ISNULL(Pydebit,0)) 'Max11',NULL AS Mode2
,MIN(Pydebit) 'Min11',AVG(Pydebit) 'Mean11',
 STDEV(Pydebit) 'Std Dev11',VAR(Pydebit) 'Variance11', (MAX(Pydebit) -MIN(Cydebit)) as Range11,
 ISNULL(STDEV(Pydebit)/SQRT(Count(Pydebit)),0) as 'STD Error11',

SUM(ISNULL(Pycredit,0)) 'Sum22',COUNT(ISNULL(Pycredit,0)) 'Count22',MAX(ISNULL(Pycredit,0)) 'Max22',NULL AS Mode3
,MIN(Pycredit) 'Min22',AVG(Pycredit) 'Mean22',
 STDEV(Pycredit) 'Std Dev22',VAR(Pycredit) 'Variance22', (MAX(Pycredit) -MIN(Pycredit)) as Range22,
 ISNULL(STDEV(Pycredit)/SQRT(Count(Pycredit)),0) as 'STD Error22'


FROM 
(
 Select 
 case when gl.GLType='PY' then isnull (gld.Debit,0) else 0 end as Pydebit,
 case when gl.GLType='PY' then isnull (gld.Credit,0) else 0 end as Pycredit,
 case when gl.GLType='CY' then isnull (gld.Debit,0) else 0 end as Cydebit,
 case when gl.GLType='CY' then isnull (gld.Credit,0) else 0 end as Cycredit
   
 From Audit.GeneralLedgerImport as gl 
 Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
 Join Audit.TrialBalanceImport as tb on tb.AccountName = gl.AccountName 
 -- Where tb.EngagementId='99729f86-2fcb-42c6-abce-26dc4de08c4f' 
 ) AS BH

) AS SK

UNION 

SELECT CAST(NULL AS INTEGER) AS Sum1,CAST(NULL AS INTEGER) AS Count1,CAST(NULL AS INTEGER) AS Max1,
CAST(NULL AS INTEGER) AS Min1,CAST(NULL AS INTEGER) AS [Std Dev1],CAST(NULL AS INTEGER) AS Variance1,
CAST(NULL AS INTEGER) AS Range1,CAST(NULL AS INTEGER) AS [STD Error1],SUM(ISNULL(Mode,0)) AS 'Mode',

CAST(NULL AS INTEGER) AS Sum2,CAST(NULL AS INTEGER) AS Count2,CAST(NULL AS INTEGER) AS Max2,
CAST(NULL AS INTEGER) AS Min2,CAST(NULL AS INTEGER) AS [Std Dev2],CAST(NULL AS INTEGER) AS Variance2,
CAST(NULL AS INTEGER) AS Range2,CAST(NULL AS INTEGER) AS [STD Error2],SUM(ISNULL(Mode,0)) AS 'Mode1',

CAST(NULL AS INTEGER) AS Sum11,CAST(NULL AS INTEGER) AS Count11,CAST(NULL AS INTEGER) AS Max11,
CAST(NULL AS INTEGER) AS Min11,CAST(NULL AS INTEGER) AS [Std Dev11],CAST(NULL AS INTEGER) AS Variance11,
CAST(NULL AS INTEGER) AS Range11,CAST(NULL AS INTEGER) AS [STD Error11],SUM(ISNULL(Mode,0)) AS 'Mode2',

CAST(NULL AS INTEGER) AS Sum22,CAST(NULL AS INTEGER) AS Count22,CAST(NULL AS INTEGER) AS Max22,
CAST(NULL AS INTEGER) AS Min22,CAST(NULL AS INTEGER) AS [Std Dev22],CAST(NULL AS INTEGER) AS Variance22,
CAST(NULL AS INTEGER) AS Range22,CAST(NULL AS INTEGER) AS [STD Error22],SUM(ISNULL(Mode,0)) AS 'Mode3'

  FROM
(


SELECT Mode,Mode1,CAST(NULL AS INTEGER) AS Mode2,CAST(NULL AS INTEGER) AS Mode3 FROM 
( 

SELECT TOP 1 gld.Debit AS Mode,CAST(NULL AS INTEGER) AS Mode1
 From Audit.GeneralLedgerImport as gl 
 Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
Where GLD.Debit is not NULL AND  GL.GLType='CY'
Group By GLD.Debit--,GL.Id
Order By Count(*) DESC
) AS A

UNION 

SELECT Mode,Mode1,CAST(NULL AS INTEGER) AS Mode2,CAST(NULL AS INTEGER) AS Mode3 FROM 
(

SELECT TOP 1 gld.Credit AS Mode,CAST(NULL AS INTEGER) AS Mode1
 From Audit.GeneralLedgerImport as gl 
 Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
Where GLD.Credit is not NULL AND  GL.GLType='CY'
Group By GLD.Credit--,GL.Id
Order By Count(*) DESC

) AS B

UNION

SELECT Mode2,Mode3,CAST(NULL AS INTEGER) AS Mode,CAST(NULL AS INTEGER) AS Mode1 FROM 
( 

SELECT TOP 1 gld.Debit AS Mode2,CAST(NULL AS INTEGER) AS Mode3
 From Audit.GeneralLedgerImport as gl 
 Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
Where GLD.Debit is not NULL AND  GL.GLType='PY'
Group By GLD.Debit--,GL.Id
Order By Count(*) DESC
) AS A

UNION 

SELECT Mode2,Mode3,CAST(NULL AS INTEGER) AS Mode,CAST(NULL AS INTEGER) AS Mode1 FROM 
(

SELECT TOP 1 gld.Credit AS Mode2,CAST(NULL AS INTEGER) AS Mode3
 From Audit.GeneralLedgerImport as gl 
 Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
Where GLD.Credit is not NULL AND  GL.GLType='PY'
Group By GLD.Credit--,GL.Id
Order By Count(*) DESC

) AS B


) AS BH
) AS P


select Name,Sum(ISNULL(CYCredit,0)) as CYCredit,SUm(ISNULL(CYDebit,0))as CYDebit,Sum(ISNULL(PYCredit,0)) as PYCredit,
SUm(ISNULL(PYDebit,0))as PYDebit from 
(
 SELECT Left(Name,8) as Name,CyCredit,Null as CYDebit,Null as PYDebit,Null as PYCredit from @TABLE1
 Unpivot(CYCredit For Name IN ([Sum     Credit],[Count    Credit],[Max     Credit],[Min     Credit],[StdDev  Credit],
 [Variance Credit],
 [Range    Credit],[StdError Credit],[Mode    Credit])) AS H
 UNION ALL
  SELECT Left(Name,8) as Name,Null as CYCredit,CYDebit,Null as PYDebit,Null as PYCredit from @TABLE1
 Unpivot(CYDebit For Name IN ([Sum     Debit],[Count    Debit],[Max     Debit],[Min     Debit],[StdDev  Debit],
 [Variance Debit],
 [Range    Debit],[StdError Debit],[Mode    Debit])) AS H

 UNION ALL

 SELECT Left(Name,8) as Name,PYCredit,Null as PYDebit,Null as CYDebit,Null as CYCredit from @TABLE1
 Unpivot(PYCredit For Name IN ([Sum     Credit],[Count    Credit],[Max     Credit],[Min     Credit],[StdDev  Credit],
 [Variance Credit],
 [Range    Credit],[StdError Credit],[Mode    Credit])) AS H
 UNION ALL
  SELECT Left(Name,8) as Name,Null as PYCredit,PYDebit,Null as CYDebit,Null as CYCredit from @TABLE1
 Unpivot(PYDebit For Name IN ([Sum     Debit],[Count    Debit],[Max     Debit],[Min     Debit],[StdDev  Debit],
 [Variance Debit],
 [Range    Debit],[StdError Debit],[Mode    Debit])) AS H

 ) as P
 Group BY Name

 END

-- ) AS BH


--SELECT Sum1 AS 'SUM',Count1 AS 'Count',SK.Max1 'Max',SK.Min1 'Min',
--SK.[Std Dev1] 'Standrad Deviation',SK.Variance1 'Sample Variance',SK.Range1 'Range',
--SK.[STD Error1] AS 'Standard Error',SK.Mode AS 'Mode'--,CAST(NULL AS INTEGER) AS
--FROM (

--SELECT SUM(ISNULL(gld.Debit,0)) 'Sum1',COUNT(ISNULL(gld.Debit,0)) 'Count1',MAX(ISNULL(gld.Debit,0)) 'Max1',NULL AS Mode
--,MIN(gld.Debit) 'Min1',AVG(gld.Debit) 'Mean1',
-- STDEV(gld.Debit) 'Std Dev1',VAR(gld.Debit) 'Variance1', (MAX(gld.Debit) -MIN(gld.Debit)) as Range1,
-- ISNULL(STDEV(gld.Debit)/SQRT(Count(gld.Debit)),0) as 'STD Error1'
--FROM AUDIT.GeneralLedgerDetail gld

--) AS SK

--UNION 

--SELECT CAST(NULL AS INTEGER) AS Sum1,CAST(NULL AS INTEGER) AS Count1,CAST(NULL AS INTEGER) AS Max1,
--CAST(NULL AS INTEGER) AS Min1,CAST(NULL AS INTEGER) AS [Std Dev1],CAST(NULL AS INTEGER) AS Variance,
--CAST(NULL AS INTEGER) AS Range1,CAST(NULL AS INTEGER) AS [STD Error1],SUM(ISNULL(Mode,0)) AS 'Mode'
--  FROM
--(

--Select Top 1 gld.Debit as Mode--,GL.Id
--From Audit.GeneralLedgerDetail gld 

--Where gld.Debit is not null
--Group By gld.Debit --,GL.Id
--Order By Count(*) DESC
--) AS BH


----UNION 

----SELECT Median = AVG(x.BaseDebit)
----FROM
----(
----   SELECT CompanyID, GL.BaseDebit, rn=ROW_NUMBER() OVER (PARTITION BY CompanyID ORDER BY GL.BaseDebit), C.InnerCount
---- FROM @My AS GL
----   CROSS APPLY (SELECT InnerCount=COUNT(*) FROM @My IGL  WHERE IGL.CompanyID=GL.CompanyID) AS C
----) AS x
----WHERE rn IN ((InnerCount + 1)/2, (InnerCount + 2)/2)
----GROUP BY CompanyID;



--End
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WeekStartEndDates]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WeekStartEndDates]  ---->> EXEC [dbo].[WeekStartEndDates] '2023-04-05',6,2
(@sdate date,@WorkWeekDays Int,@RowNumber INT)
AS
BEGIN

Declare @workWeeks Table (
    weekStart datetime,
    weekEnd datetime,
    weekText varchar(25)
)

Declare @count int,
        @StartDate datetime,
        @EndDate datetime
Select  @count = 0,
        @StartDate = DATEADD(DAY, DATEDIFF(DAY, -1, @sdate) / 7 * 7, 0),
        @EndDate = DATEADD(MS, -3, DATEADD(DAY, DATEDIFF(DAY, -1, @sdate) / 7 * 7, @WorkWeekDays)) -- Next Sunday minus 3



While @count < 52
Begin
    Insert Into @workWeeks Values(
        DATEADD(WK, +@count, @StartDate),
        DATEADD(WK, +@count, @EndDate),
        CONVERT(varchar, DATEADD(WK, -@count, @StartDate), 101) + ' - ' + CONVERT(varchar, DATEADD(WK, -@count, @EndDate), 101))
    Set @count = @count + 1
End


SELECT * FROM (
Select *,ROW_NUMBER() OVER (ORDER BY weekStart) AS [WeekOrder]  From @workWeeks
) AS A
WHERE [WeekOrder] <= @RowNumber
ORDER BY weekStart

END
GO

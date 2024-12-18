USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_HTML_Status_Dashboard]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure[dbo].[BR_HTML_Status_Dashboard]  
	@FromDate Datetime,
	@ToDate Datetime,
	@CompanyId BIGINT,
	@Role varchar(100)
AS
BEGIN

--  EXEC [dbo].[BR_HTML_Entity_Dashboard] '2020-01-01','2020-05-01',689,null

SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)
IF @Role is null
Begin

EXEC [dbo].[BR_HTML_Status_ControllerDashboard] @FromDate,@ToDate,@CompanyId,@Role
END
ELSE
	Begin
EXEC [dbo].[BR_HTML_Status_MyDashboard] @FromDate,@ToDate,@CompanyId,@Role
END
End
GO

USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Update_Remarks_BizApp_Inv]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [dbo].[Update_Remarks_BizApp_Inv]
as
begin
---------------------------- exec Update_Remarks_BizApp_Inv

DECLARE @CompanyId INT =1
update I SET I.Remarks=b.BizApp_Inv FROM  WorkFlow.Invoice I
INNER JOIN Bizapp_Reference B ON B.SC_Inv=I.Number
WHERE CompanyId=@CompanyId

end 
GO

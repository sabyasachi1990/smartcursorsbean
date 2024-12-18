USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_OPENINGBALANCE_DELETE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_OPENINGBALANCE_DELETE](@Id UNIQUEIDENTIFIER)
AS
BEGIN 
DELETE t3 
FROM Bean.OpeningBalanceDetailLineItem t3 
JOIN Bean.OpeningBalanceDetail t2 ON t2.Id = t3.OpeningBalanceDetailId
JOIN Bean.OpeningBalance t1 ON t1.Id = t2.OpeningBalanceId 
WHERE t1.Id = @Id;

DELETE t2 
FROM Bean.OpeningBalanceDetail t2 
JOIN Bean.OpeningBalance t1 ON t1.Id = t2.OpeningBalanceId
WHERE t1.Id = @Id;

--DELETE FROM Bean.OpeningBalance WHERE Id = @Id;

END;
GO

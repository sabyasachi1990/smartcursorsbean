USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DEPARTMENT_TELERIK]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

  CREATE PROCEDURE [dbo].[DEPARTMENT_TELERIK]
   
 @Department Nvarchar(MAX) 
 AS
 BEGIN
  SELECT  CompanyId,NAME,Code FROM 
  
  Common.Department WHERE CODE IN 
   (select items from dbo.SplitToTable(@Department,',')) and CompanyId=1
   END 
GO

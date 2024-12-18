USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Support_Testing_Companyuser_PBI]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Support_Testing_Companyuser_PBI]
AS
BEGIN


 select  Distinct  bb.UserId,CompanyName,ua.FirstName,ua.UserCreated,PaternerCompany from 
(
select Distinct UserId,Name AS CompanyName,PaternerCompany from 
(
Select RANK() OVER (PARTITION BY ticketid ,userid ORDER BY r.createdDate Desc) AS Rank,UserId,TicketId,r.CreatedDate,c.Name,
case when c.IsAccountingFirm=1 then c.Name end as PaternerCompany
 from Support.TicketReply r
 left join Common.Company c on c.id=r.CompanyId
 )as AA
 where Rank=1
 )as BB 
inner join Auth.UserAccount ua on ua.Id=bb.UserId
END
GO

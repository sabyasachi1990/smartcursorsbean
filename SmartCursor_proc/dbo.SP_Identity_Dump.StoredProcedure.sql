USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Identity_Dump]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SP_Identity_Dump]  
@FromDB nvarchar(150) ,
 @ToDB nvarchar(150) 
 AS 
 BEGIN 
 DECLARE
 @query1 nvarchar(max),
 @query2 nvarchar(max)
set @query1=CONCAT('INSERT INTO ',@ToDB,'.[dbo].[AspNetUsers]  
SELECT ID as Id,0 AS AccessFailedCount,NEWID() as ConcurrencyStamp,Email AS Email,1 AS EmailConfirmed,1 AS LockoutEnabled,Null as LockoutEnd ,UPPER (Email) AS NormalizedEmail,UPPER(Username) AS NormalizedUserName,''AQAAAAEAACcQAAAAEKL3bzdrB51WJ4/zL2VQ37Tzr+Gv7INsxfx/9M+aph7ZnLDrFCsd1+1FsBPglAo9fQ=='' AS PasswordHash,''123456789'' AS PhoneNumber,1 AS PhoneNumberConfirmed,NEWID() AS SecurityStamp,0 AS TwoFactorEnabled,Username AS UserName
from [',@FromDB,'].[dbo].[UserAccounts]')
set @query2 = CONCAT('INSERT INTO ',@ToDB,'.dbo.[AspNetUserClaims] 
select  [Type] AS ClaimType,[Value] AS ClaimValue, ua.ID AS UserId from [',@FromDB,'].[dbo].UserAccounts ua join [',@FromDB,'].[dbo].[UserClaims] uc on ua.[Key]=uc.ParentKey')
   EXECUTE sp_executesql  @query1;
   EXECUTE sp_executesql  @query2;
   END
GO

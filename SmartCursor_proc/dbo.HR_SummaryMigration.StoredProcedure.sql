USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_SummaryMigration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[HR_SummaryMigration] @AppraisalId uniqueidentifier , @AppraiseeId uniqueidentifier
 As
 begin
 declare @SummayContent NVARCHAR(Max)=''
 declare @summary1 NVARCHAR(Max) =''
  declare @summary2  NVARCHAR(Max) =''
   declare @summary3  NVARCHAR(Max) =''
    declare @summary4  NVARCHAR(Max) =''
     declare @summary5  NVARCHAR(Max) =''
      declare @summary6  NVARCHAR(Max) =''
       declare @summary7  NVARCHAR(Max) =''
        declare @summary8  NVARCHAR(Max) =''
         declare @summary9  NVARCHAR(Max) =''
          declare @summary10  NVARCHAR(Max) =''
           declare @summary11  NVARCHAR(Max) =''
            declare @summary12  NVARCHAR(Max) =''


        set @summary1 = '<p> '+ (select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 0 row  fetch next 1 row only ) + ' </p> <br> '
        set @summary2 = '<p> '+(select   [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 1 row  fetch next 1 row only ) +  ' </p> <br> '
        set @summary3 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 2 row  fetch next 1 row only ) +  ' </p> <br> '
        set @summary4 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 3 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary5 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 4 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary6 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 5 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary7 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 6 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary8 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 7 row  fetch next 1 row only) + ' </p> <br> '
        set @summary9 = '<p> '+(select  [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 8 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary10 = '<p> '+(select [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 9 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary11 = '<p> '+(select [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 10 row  fetch next 1 row only) +  ' </p> <br> '
        set @summary12 = '<p> '+(select [Summary] from [HR].[AppraisalSummary] where [AppraisalId] = @AppraisalId and [AppraiseeId] = @AppraiseeId order by [AppraisalId] offset 11 row  fetch next 1 row only) +  ' </p> <br> '


        if(@summary1 is  null)
        begin
        set @summary1 = ''
        end
        
        if(@summary2 is  null)
        begin
        set @summary2 = ''
        end
        
        if(@summary3 is  null)
        begin
        set @summary3 = ''
        end
        
        if(@summary4 is null)
        begin
        set @summary4 = ''
        end
        
        if(@summary5 is null)
        begin
        set @summary5 = ''
        end
        
        if(@summary6 is  null)
        begin
        set @summary6 = ''
        end
        
        if(@summary7 is null)
        begin
        set @summary7 = ''
        end
        
        if(@summary8 is null)
        begin
        set @summary8 = ''
        end
        
        if(@summary9 is null)
        begin
        set @summary9 = ''
        end
        
        if(@summary10 is  null)
        begin
        set @summary10 = ''
        end
        
        if(@summary11 is null)
        begin
        set @summary11 = ''
        end
        
        if(@summary12 is null)
        begin
        set @summary12 = ''
        end
        
        set @SummayContent ='<!DOCTYPE html> <html> <head> </head> <body>'+ ((@summary1) +(@summary2) +(@summary3) +(@summary4) +@summary5 + @summary6 + @summary7 +@summary8 + @summary9 + @summary10 + @summary11 +@summary12 ) + '</body> </html>'


        update [HR].[AppraisalAppraiseeDetails] set TemplateContent = @SummayContent where AppraisalId = @AppraisalId and EmployeeId =  @AppraiseeId
    end

GO

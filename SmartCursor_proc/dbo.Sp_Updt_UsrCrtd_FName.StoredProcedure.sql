USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Updt_UsrCrtd_FName]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[Sp_Updt_UsrCrtd_FName] 
@colName Varchar(max)
As
Begin
--Declare @colName Varchar(max)='UserCreated,ModifiedBy,User'
--Select items from [dbo].[SplitToTable] (@colName,',')
Declare @TableName varchar(Max),
@SchemaName varchar(Max),
@Usr_ColumnName varchar(Max),
@TblName varchar(Max),
@ColumnName Varchar(Max),
@Updt_Tbl varchar(Max),
@Updt_Tb2 varchar(Max)
-- Getting Columns from the parameter using coma separator
-- Declare First Cursor 
Declare Col_NameCsr Cursor For
Select items from [dbo].[SplitToTable] (@colName,',')
Open Col_NameCsr -- Open First cursor
Fetch Next From Col_NameCsr Into @Usr_ColumnName
While @@FETCH_STATUS=0
Begin
Print '============'
Print @Usr_ColumnName
Print '============'
-- Declare Second Cursor
Declare Tbl_Names_Csr cursor For
SELECT t.name AS table_name, SCHEMA_NAME(schema_id) AS schema_name , c.name
FROM sys.tables AS t INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID 
WHERE c.name = @Usr_ColumnName 
ORDER BY schema_name, table_name

Open Tbl_Names_Csr --Open Second cursor

Fetch Next From Tbl_Names_Csr Into @TableName,@SchemaName,@ColumnName

While @@FETCH_STATUS=0
Begin
--Get The table name Adding scheama Name & Table Name
Set @TblName = Concat(@SchemaName,'.','[',@TableName,']')

Print @TblName

Begin
-- Update every Table with firstname from Common.CompanyUser
Set @Updt_Tbl=' UPDATE T1 Set T1.'+@ColumnName+' = T2.FirstName From '+@TblName+' As T1 Inner Join Common.CompanyUser As T2 On T1.'+@ColumnName+' = T2.Username'

Exec (@Updt_Tbl)

End

Fetch Next From Tbl_Names_Csr Into @TableName,@SchemaName,@ColumnName

End

Close Tbl_Names_Csr --Close Second Cursor
Deallocate Tbl_Names_Csr -- Deallocate Second Cursor

Fetch Next From Col_NameCsr Into @Usr_ColumnName

End

Close Col_NameCsr --Close First Cursor
Deallocate Col_NameCsr -- Deallocate First Cursor
END
GO

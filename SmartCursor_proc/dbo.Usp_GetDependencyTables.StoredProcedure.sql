USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDependencyTables]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_GetDependencyTables]
@In_TableName VARCHAR(200),
@In_ColName VARCHAR(200),
@In_IntID nvarchar(400)
AS
BEGIN
CREATE TABLE #FKDependentTables(ID INT IDENTITY,TableName VARCHAR(100),ColName NVARCHAR(MAX))
INSERT INTO #FKDependentTables(TableName,ColName)
SELECT SCHEMA_NAME(t.schema_id)+'.'+t.name,c.name
FROM sys.foreign_key_columns as fk
INNER JOIN sys.tables as t on fk.parent_object_id = t.object_id
INNER JOIN sys.tables as t1 on fk.referenced_object_id = t1.object_id
INNER JOIN sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
WHERE t1.object_id = (Select OBJECT_ID(@In_TableName))
 and fk.referenced_column_id = (SELECT column_id FROM sys.columns WHERE name = @In_ColName and object_id = t1.object_id)

--SELECT * FROM #FKDependentTables
DECLARE @Cnt INT 
SELECT @CNT = COUNT(*) FROM #FKDependentTables
DECLARE @TableName NVARCHAR(4000)
DECLARE @ColName NVARCHAR(MAX)
DECLARE @Qry NVARCHAR(200)
DECLARE @RowResult INT
DECLARE @RowCntOut INT


CREATE TABLE #FKDependentResultTables(ID INT IDENTITY,TableName VARCHAR(100))


WHILE @Cnt > 0
BEGIN
	SELECT @TableName = TableName FROM #FKDependentTables WHERE ID = @Cnt
	SELECT @ColName = ColName FROM #FKDependentTables WHERE ID = @Cnt
	
	SET @Qry = 'SELECT @RowCntOut = COUNT(*) FROM ' + @TableName +' WHERE '+ @ColName +'='''+ cast(@In_IntID as nvarchar(100))+''''
	Execute SP_Executesql @Qry,N'@RowCntOut INT output',@RowCntOut= @RowResult output
	--select @RowResult
	IF @RowResult > 0
	   INSERT INTO #FKDependentResultTables(TableName)
	   SELECT @TableName
	   
	   
	SET @Cnt -= 1
	
END

SELECT * From #FKDependentResultTables

END
GO

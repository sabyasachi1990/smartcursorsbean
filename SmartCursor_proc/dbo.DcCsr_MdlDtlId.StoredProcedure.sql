USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DcCsr_MdlDtlId]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[DcCsr_MdlDtlId] @NewCompId Bigint --->> EXEC [dbo].[DcCsr_MdlDtlId] 2058
AS
BEGIN

DROP TABLE IF EXISTS #UpdateTable
DROP TABLE IF EXISTS #VariableData

--DECLARE @NewCompId BIGINT = 2058
DECLARE @UNIQUE_COMPANY_ID BIGINT = 0
DECLARE  @ModuleDtl_Id NVARCHAR(250)
DECLARE @ModuleDetailId Nvarchar(2000), @Heading nvarchar(200), @Counter BigInt = 1, @MaxCounter BigInt

CREATE TABLE #UpdateTable (SNo Int Identity(1,1),CompanyId BigInt, ModuleDetailId nvarchar(100),UpdateData Nvarchar(100),Heading varchar(200))
CREATE TABLE #VariableData (SNo Int Identity(1,1), ModuleDetailId NVARCHAR(Max), Heading varchar(100))

INSERT INTO #VariableData(ModuleDetailId,Heading)
SELECT ModuleDetailId, Heading FROM Common.ModuleDetail WITH (NOLOCK)
WHERE CompanyId = @UNIQUE_COMPANY_ID
	AND ModuleMasterId = ( 	SELECT Id FROM Common.ModuleMaster WITH (NOLOCK) WHERE Name = 'Doc Cursor' )
	AND ModuleDetailId IS NOT NULL


SET @MaxCounter = (SELECT COUNT(ModuleDetailId) FROM #VariableData)

WHILE @Counter <= @MaxCounter
BEGIN
	SELECT @ModuleDetailId = ModuleDetailId, @Heading = Heading FROM #VariableData WHERE SNo = @Counter	

		SET @ModuleDtl_Id = NULL
		SELECT @ModuleDtl_Id = COALESCE(@ModuleDtl_Id + ', ', '') + Cast(Id AS NVARCHAR)
		FROM (
			SELECT DISTINCT Md.Id
			FROM Common.ModuleDetail AS Md WITH (NOLOCK)
			INNER JOIN (
				SELECT *
				FROM Common.ModuleDetail WITH (NOLOCK)
				WHERE id IN (
						SELECT Items
						FROM SplitToTable(@ModuleDetailId, ',')
						)
				) AS Md2 ON Isnull(Md2.GroupName, 'Null') = ISNULL(Md.GroupName, 'Null')
				AND Md2.Heading = Md.Heading
				AND Md2.ModuleMasterId = Md.ModuleMasterId
				AND ISNULL(Md2.PermissionKey, 0) = ISNULL(Md.PermissionKey, '0')
				AND Isnull(Md2.SecondryModuleId, 0) = ISNULL(Md2.SecondryModuleId, 0)
			WHERE Md.CompanyId = @NewCompId --And Md.ParentId Is Null
			) AS A

---------->>>> Update Query
		INSERT INTO #UpdateTable (CompanyId,ModuleDetailId,UpdateData,Heading)
		SELECT Up_Md.CompanyId,Up_Md.ModuleDetailId, @ModuleDtl_Id AS UpdateData,Up_Md.Heading
		FROM Common.ModuleDetail AS Up_Md WITH (ROWLOCK)
		INNER JOIN (
			SELECT *
			FROM Common.ModuleDetail WITH (NOLOCK)
			WHERE CompanyId = @UNIQUE_COMPANY_ID
				AND ModuleMasterId = (
					SELECT Id
					FROM Common.ModuleMaster WITH (NOLOCK)
					WHERE Name = 'Doc Cursor'
					)
				AND Heading = @Heading
			) AS Up_Md1 ON Up_Md1.Heading = Up_Md.Heading
			AND Isnull(Up_Md1.GroupName, 'Null') = ISNULL(Up_Md.GroupName, 'Null')
			AND ISNULL(Up_Md1.PermissionKey, 0) = ISNULL(Up_Md.PermissionKey, 0)
			AND ISNULL(Up_Md1.SecondryModuleId, 0) = ISNULL(Up_Md.SecondryModuleId, 0)
			AND Up_Md1.ModuleMasterId = Up_Md.ModuleMasterId
		WHERE Up_Md.CompanyId = @NewCompId

	SET @Counter = @Counter + 1
END

--->>> SELECT DISTINCT ModuleDetailId,UpdateData  FROM #UpdateTable ORDER BY ModuleDetailId ASC

UPDATE  A  SET A.ModuleDetailId = UpdateData FROM Common.ModuleDetail As A INNER JOIN #UpdateTable AS B ON B.ModuleDetailId = A.ModuleDetailId AND A.CompanyId = B.CompanyId

SELECT * INTO #IsHide
FROM (
		SELECT Id,IsHide FROM Common.ModuleDetail (NOLOCK)  WHERE ParentId IS NOT NULL AND (IsHide <> 1 OR IsHide IS NULL)
	) AS A

UPDATE A SET IsHide = 1  FROM Common.ModuleDetail AS A 
INNER JOIN #IsHide AS B ON B.Id = A.Id

DROP TABLE IF EXISTS #IsHide

END


--------=================================================== OLD PROCEDURE ===================================================-------
----ALTER Procedure [dbo].[DcCsr_MdlDtlId]
----@NewCompId Bigint
----As
----Begin
----Declare @UNIQUE_COMPANY_ID bigint=0

----Declare @ModuleDtlId Nvarchar(Max),
----		@Heading Nvarchar(150),
----		@ModuleDtl_Id Nvarchar(250),
----		@Count Int
		
----	Declare Module_Dtl Cursor For
----		Select ModuleDetailId,Heading from Common.ModuleDetail WITH (NOLOCK) Where CompanyId=@UNIQUE_COMPANY_ID
----				And ModuleMasterId=(Select Id from Common.ModuleMaster WITH (NOLOCK) Where Name='Doc Cursor') 
----				And ModuleDetailId Is not null 
----		Open Module_Dtl
----		Fetch Next From Module_Dtl Into @ModuleDtlId,@Heading
----		While @@FETCH_STATUS=0
----		Begin
----		Select @Count=CHARINDEX(',',@ModuleDtlId)
----		If @Count<>0
----		Begin
----		--Select Items From SplitToTable(@ModuleDtlId,',')
----		Set @ModuleDtl_Id=null
----		Select @ModuleDtl_Id=COALESCE(@ModuleDtl_Id + ', ', '') + Cast(Id As nvarchar) from 
----         (
----         Select distinct Md.Id from Common.ModuleDetail As Md WITH (NOLOCK)
----         Inner Join (Select * from Common.ModuleDetail WITH (NOLOCK) Where id in (Select Items From SplitToTable(@ModuleDtlId,','))) As Md2 On Isnull(Md2.GroupName,'Null')=ISNULL(Md.GroupName,'Null')     And Md2.Heading=Md.Heading And Md2.ModuleMasterId=Md.ModuleMasterId And ISNULL(Md2.PermissionKey,0)=ISNULL(Md.PermissionKey,'0')
----         		And Isnull(Md2.SecondryModuleId,0)=ISNULL(Md2.SecondryModuleId,0) 
----         	Where Md.CompanyId=@NewCompId --And Md.ParentId Is Null
----         ) As A

----		 Update Up_Md  Set Up_Md.ModuleDetailId=@ModuleDtl_Id From Common.ModuleDetail As Up_Md WITH (ROWLOCK)
----         Inner Join (Select * from Common.ModuleDetail WITH (NOLOCK) Where CompanyId=@UNIQUE_COMPANY_ID And ModuleMasterId=(Select Id from Common.ModuleMaster WITH (NOLOCK) Where Name='Doc Cursor')
----				And Heading=@Heading) As Up_Md1 On Up_Md1.Heading=Up_Md.Heading 
----         		And Isnull(Up_Md1.GroupName,'Null')=ISNULL(Up_Md.GroupName,'Null') And ISNULL(Up_Md1.PermissionKey,0)=ISNULL(Up_Md.PermissionKey,0)
----         		And ISNULL(Up_Md1.SecondryModuleId,0)=ISNULL(Up_Md.SecondryModuleId,0) And Up_Md1.ModuleMasterId=Up_Md.ModuleMasterId
----         		Where Up_Md.CompanyId=@NewCompId

----        Update Common.ModuleDetail WITH (ROWLOCK) set IsHide=1 where ParentId is not null
----		End
----		Else
----		Begin
----		Set @ModuleDtl_Id=null
----		Select @ModuleDtl_Id=COALESCE(@ModuleDtl_Id + ', ', '') + Cast(Id As nvarchar) from 
----         (
----         Select distinct Md.Id from Common.ModuleDetail As Md WITH (NOLOCK)
----         Inner Join (Select * from Common.ModuleDetail WITH (NOLOCK) Where id =@ModuleDtlId) As Md2 On Isnull(Md2.GroupName,'Null')=ISNULL(Md.GroupName,'Null')     And Md2.Heading=Md.Heading And Md2.ModuleMasterId=Md.ModuleMasterId And ISNULL(Md2.PermissionKey,0)=ISNULL(Md.PermissionKey,'0')
----         		And Isnull(Md2.SecondryModuleId,0)=ISNULL(Md2.SecondryModuleId,0) 
----         	Where Md.CompanyId=@NewCompId --And Md.ParentId Is Null
----         ) As A

----		 Update Up_Md Set Up_Md.ModuleDetailId=@ModuleDtl_Id From Common.ModuleDetail As Up_Md WITH (ROWLOCK)
----         Inner Join (Select * from Common.ModuleDetail WITH (NOLOCK) Where CompanyId=@UNIQUE_COMPANY_ID And ModuleMasterId=(Select Id from Common.ModuleMaster WITH (NOLOCK) Where Name='Doc Cursor')
----				And Heading=@Heading) As Up_Md1 On Up_Md1.Heading=Up_Md.Heading 
----         		And Isnull(Up_Md1.GroupName,'Null')=ISNULL(Up_Md.GroupName,'Null') And ISNULL(Up_Md1.PermissionKey,0)=ISNULL(Up_Md.PermissionKey,0)
----         		And ISNULL(Up_Md1.SecondryModuleId,0)=ISNULL(Up_Md.SecondryModuleId,0) And Up_Md1.ModuleMasterId=Up_Md.ModuleMasterId
----         		Where Up_Md.CompanyId=@NewCompId
----		Update Common.ModuleDetail WITH (ROWLOCK) set IsHide=1 where ParentId is not null
----		End

----		Fetch Next From Module_Dtl Into @ModuleDtlId,@Heading
----		End

----		Close Module_Dtl
----		Deallocate Module_Dtl
----	End
-------------------------------------------------------------------------------------------------
GO

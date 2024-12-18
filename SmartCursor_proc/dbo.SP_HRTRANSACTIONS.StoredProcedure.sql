USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HRTRANSACTIONS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [dbo].[SP_HRTRANSACTIONS] 10, 'D:\HR_NEW Excel.xlsx','HR Cursor-Employees','8FD91D2C-E000-41EC-A38D-444C322B493B'

CREATE PROCEDURE [dbo].[SP_HRTRANSACTIONS](@COMPANYID BIGINT, @FILEPATH NVARCHAR(MAX),@TYPE NVARCHAR(100),@TRANSACTIONID NVARCHAR(100))
AS 
 BEGIN 

  	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
	--CONFIGURING SQL INSTANCE TO ACCEPT ADVANCED OPTIONS
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE
	--ENABLING USE OF DISTRIBUTED QUERIES
	EXEC sp_configure 'Ad Hoc Distributed Queries', 1
	RECONFIGURE


	 IF(@TYPE='HR Cursor-Employees')
	  
	 BEGIN
	         DECLARE  @PersonalDetails TABLE (EmployeeID Nvarchar(100),Name nvarchar(100),IdType nvarchar(50),IdNumber Nvarchar(100),Nationality Nvarchar(50),Race Nvarchar(50)
			 ,DateOfBirth nvarchar(50),Age int,Gender nvarchar(50),MaritalStatus nvarchar(100),PassportNumber  NVARCHAR(100),PassportExpiry NVARCHAR(100),
	         UserName NVARCHAR(100),LocalAddress nvarchar(max),ForeignAddress nvarchar(max),Email NVARCHAR(100) ,Phone NVARCHAR(100))																											  											
	         																																														  
	         Declare @P nvarchar(max)
	         
	         Set @P=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Personal Details$A1:Q]'')'   
	         
	         INSERT INTO @PersonalDetails 
		     EXEC(@P)
			-- SELECT * FROM @PersonalDetails

			 INSERT INTO dbo.ImportPersonalDetails (ID,TransactionId,EmployeeId,Name,IdType,IdNumber,Nationality,Race,DateofBirth,Age,Gender,MaritalStatus,PassPortNumber,PassportExpiry,UserName,LocalAddress,ForeignAddress,Email,Mobile)
			 Select  newid(),@TRANSACTIONID,EmployeeID,Name,IdType,IdNumber,Nationality,Race,DateOfBirth,Age,Gender,MaritalStatus,PassportNumber,PassportExpiry,UserName,LocalAddress,ForeignAddress,Email,Phone from  @PersonalDetails where EmployeeID is not null

       --  END


	
	  
	-- BEGIN
	         DECLARE  @EMPLOYMENT TABLE (EmployeeID Nvarchar(100),TypeofEmployment Nvarchar(100),EmployementStartDate Nvarchar(100),EmployementEndDate Nvarchar(100),
	         Period nvarchar(50),[Days/Months] int,ConfirmationDate Nvarchar(100),ConfirmationRemarks Nvarchar(max),RejoinDate Nvarchar(100),EntityName nvarchar(100),
			 Department nvarchar(100),Designation nvarchar(100),Level int,Reporting nvarchar(100),EffectiveFrom Nvarchar(100),Currency nvarchar(100),MonthlyBasicPay nvarchar(100),
			 ChargeoutRate nvarchar(100))																											  											
	         																																														  
	         Declare @Emp nvarchar(max)
	         
	         Set @Emp=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Employment$A1:R]'')'   
         
	         INSERT INTO @EMPLOYMENT 
		     EXEC(@Emp)
			-- SELECT * FROM @EMPLOYMENT
			INSERT INTO dbo.ImportEmployment (ID,TransactionId,EmployeeId,TypeofEmployment,EmploymentStartDate,EmploymentEndDate,Period,[Days/Months],ConfirmationDate,ConfirmationRemarks,RejoinDate)
			SELECT NEWID(),@TRANSACTIONID,EmployeeID,TypeofEmployment,EmployementStartDate,EmployementEndDate,Period,[Days/Months],ConfirmationDate,ConfirmationRemarks,RejoinDate FROM @EMPLOYMENT where EmployeeID is not null

			INSERT INTO dbo.ImportEmployeeDepartment(ID,TransactionId,EmployeeId,EntityName,Department,Designation,Level,ReportingTo,EffectiveFrom,Currency,MonthlyBasicPay,ChargeOutRate)
			SELECT NEWID(),@TRANSACTIONID,EmployeeID,EntityName,Department,Designation,Level,Reporting,EffectiveFrom,Currency,MonthlyBasicPay,ChargeoutRate  FROM @EMPLOYMENT WHERE EmployeeID IS NOT NULL
        -- END



	  
	-- BEGIN
	         DECLARE  @QUALIFICATION TABLE (EmployeeId Nvarchar(100),Type Nvarchar(100),Qualification nvarchar(100),Instituation nvarchar(100),
			 StartDate Nvarchar(100),EndDate Nvarchar(100),Attachments nvarchar(max))																											  											
	         																																														  
	         Declare @QUL nvarchar(max)
	         
	         Set @QUL=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Qualification$A1:G]'')'   
	         
	         INSERT INTO @QUALIFICATION 
		     EXEC(@QUL)
			-- SELECT * FROM @QUALIFICATION
			INSERT INTO DBO.ImportQualification (ID,TransactionId,EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments)
			SELECT NEWID(),@TRANSACTIONID,EmployeeId,Type,Qualification,Instituation,StartDate,EndDate,Attachments FROM @QUALIFICATION WHERE EmployeeId IS NOT NULL 
      --   END



		
	  
	-- BEGIN
	         DECLARE  @FAMILY TABLE (EmployeeId Nvarchar(100),Name nvarchar(100),Relation nvarchar(100),Nationality nvarchar(50),IDNo nvarchar(100),
	         DateOfBirth Nvarchar(100),Age int,ContactNo nvarchar(100),NameofEmployer  nvarchar(100),EmergencyContact bit)																											  											
	         																																														  
	         Declare @Fam nvarchar(max)
	         
	         Set @Fam=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Family$A1:J]'')'  
	         
	         INSERT INTO @FAMILY 
		     EXEC(@Fam)
			 --SELECT * FROM @FAMILY

			 INSERT INTO DBO.ImportFamily(ID,TransactionId,EmployeeId,Name,Relation,Nationality,IDNo,DateofBirth,Age,ContactNo,[NameofEmployer/School],EmergencyContact)
			 SELECT NEWID(),@TRANSACTIONID,EmployeeId,Name,Relation,Nationality,IDNo,DateOfBirth,AGE,ContactNo,NameofEmployer,EmergencyContact FROM @FAMILY WHERE EmployeeId IS NOT NULL 
         END
	 END

GO

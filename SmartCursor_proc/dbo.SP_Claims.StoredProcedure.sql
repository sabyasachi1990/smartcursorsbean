USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Claims]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Claims](@COMPANYID BIGINT, @FILENAME NVARCHAR(MAX))
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

	-- New way to read the Excel data-------------------------
	DECLARE  @TDates TABLE (DATEANDTIMES DATETIME2(7))
	DECLARE  @MonthwiseDates TABLE (MonthwiseDates Date)
	DECLARE  @T TABLE (claim NVARCHAR(100),Id uniqueidentifier)
	
	Declare @Route VARCHAR(4000)
	Declare @sql nvarchar(max)
	--Set @Route='D:\Appsworld.Attendance1.xlsx'
	Set @sql=' SELECT * FROM OPENROWSET(
		            ''Microsoft.ACE.OLEDB.12.0'',
		            ''Excel 12.0 xml;HDR=YES;Database=' + @FILENAME + ''',  
		            ''SELECT * FROM [Sheet1$]'')'   --'D:\Appsworld.Attendance1.xlsx' in 192.168.0.110
		   begin
	   insert into @T Exec(@sql)  
	   --insert into [dbo].[Tempclaims]  select Id,claim from @T

	   select * from  @T
	   end

end


















GO

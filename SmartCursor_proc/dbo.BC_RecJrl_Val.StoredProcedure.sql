USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_RecJrl_Val]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[BC_RecJrl_Val] 

	@Fromdate Datetime2,
	@Enddate Datetime2,
	@Frequancy Int,
	@TaxId Nvarchar(500),
	@CompanyId Int
	

	As
	Begin
	--// Declaring Variables to store count of taxid's in parameter & Matched Taxid's From table
		Declare @TaxId_PmtCount Int,
				@Taxid_TblCount Int,
				@ValidationOP Int 
	--// Write A Select Statement to get the count of taxid's form a input parameter
		Select @TaxId_PmtCount=count(Items) From  (Select distinct Items From [dbo].[SplitToTable] (@TaxId,',')) As A
	--// Assign the systemdate to the enddate parameter while it is null
		If @Enddate Is null
			Begin
			Set @Enddate=GETDATE()
			End
	--// Using While loop to increase the from date based on freaquency parameter
		While @Fromdate <= @Enddate 
		Begin
	--// Getting the taxid's count that are matching with table data 
		Select @Taxid_TblCount=count(*) From Bean.TaxCode Where Id in (Select distinct Items From [dbo].[SplitToTable] (@TaxId,',')) 
				And @Fromdate Between EffectiveFrom And coalesce(EffectiveTo,Getdate())
	--// Add Date To fromdate Parameter Based on Freaquency
		Set @Fromdate=DATEADD(MM,@Frequancy,@Fromdate)
	--// Check the taxid's count from Parameter And Table if count mismatch update fromdate with followed date of Enddate to break the while loop
			If @TaxId_PmtCount != @Taxid_TblCount
				Begin
					Set @Fromdate=DATEADD(MM,1,@Enddate)
					Set @ValidationOP=0
				End
			Else 
				Begin
					Set @ValidationOP=1
				End
		End
	--// Print The @ValidationOP Variable value 
		Begin
			Print @ValidationOP
		End
	End
GO

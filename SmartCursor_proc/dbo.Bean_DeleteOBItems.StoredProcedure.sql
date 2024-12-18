USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_DeleteOBItems]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Bean_DeleteOBItems]  
		@CompanyId Bigint,
		@OpeningBalanceId Uniqueidentifier,
		@OBDIds Nvarchar(Max),
		@OBDLIIds Nvarchar(Max)

As 
Begin
	Begin Transaction
	Begin Try
		If(@OBDLIIds is not null And @OBDLIIds<>'')
		BEGIN
		-- // Delete From CreditMemoDetail
			Delete From  CMD From Bean.CreditMemoDetail As CMD
			Inner Join Bean.CreditMemo As CM on CM.Id=CMD.CreditMemoId
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=CM.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And CM.DocumentState='Not Applied'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From BillDetail
			Delete From  BD From Bean.BillDetail As BD
			Inner Join Bean.Bill As B on B.Id=BD.BillId
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=B.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And B.DocumentState='Not Paid'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

			--Delete from InvoiceNote Table
			Delete From  InvNote From Bean.InvoiceNote As InvNote
			Inner Join Bean.Invoice As Inv on Inv.Id=InvNote.InvoiceId
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=Inv.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And Inv.DocumentState='Not Paid'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From Invoice Detail
			Delete From  Ind From Bean.InvoiceDetail As Ind
			Inner Join Bean.Invoice As Inv on Inv.Id=Ind.InvoiceId
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=Inv.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And Inv.DocumentState='Not Paid'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

			-- // Delete From CreditNote Detail
			Delete From  Ind From Bean.InvoiceDetail As Ind
			Inner Join Bean.Invoice As Inv on Inv.Id=Ind.InvoiceId
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=Inv.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And Inv.DocumentState='Not Applied'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))


		-- // Delete From CreditMemo
			
			Delete From CM from Bean.CreditMemo As CM 			
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=CM.Id 
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.ID=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And CM.DocumentState='Not Applied'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From Bill
			Delete From  B From Bean.Bill As B
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=B.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And B.DocumentState='Not Paid'
			And OB.Id=@OpeningBalanceId
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From Invoice
			Delete From  Inv From Bean.Invoice As Inv
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=Inv.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And Inv.DocumentState='Not Paid'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

			-- // Delete From Credit Note
			Delete From  Inv From Bean.Invoice As Inv
			Inner Join Bean.OpeningBalanceDetailLineItem As OBDL On OBDL.Id=Inv.Id
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And Inv.DocumentState='Not Applied'
			And OB.Id=@OpeningBalanceId 
			And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From OpeningBalanceDetailLineItem 
			Delete From  OBDL From Bean.OpeningBalanceDetailLineItem As OBDL
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=@CompanyId And OB.Id=@OpeningBalanceId 
				And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))

		-- // Delete From OpeningBalanceDetailLineItem 
			Delete From  OBDL From Bean.OpeningBalanceDetailLineItem As OBDL
			Inner Join Bean.OpeningBalanceDetail As OBD On OBD.Id=OBDL.OpeningBalanceDetailId
			Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
			Where OB.CompanyId=0 And OB.Id=@OpeningBalanceId 
				And OBDL.Id in (Select items From dbo.SplitToTable (@OBDLIIds,','))
		END

	-- // Delete From OpeningBalanceDetail 
		If(@OBDIds is not null And @OBDIds<>'')
		BEGIN
			Declare @Count Int,
					@OPBIdCount Int=1

			Declare @Temp table (S_No Int Identity(1,1),OPDId Uniqueidentifier)
		--// Declare Temp Variable To Store Opening Balance Detail Id's 
			Insert Into @Temp (OPDId)
			Select Items From [dbo].[SplitToTable] (@OBDIds,',')

			Select @Count=count(Items) From [dbo].[SplitToTable] (@OBDIds,',')

			While @OPBIdCount<=@Count

			Begin
				IF Not Exists (Select Id From Bean.OpeningBalanceDetailLineItem Where OpeningBalanceDetailId =(Select OPDId From @Temp Where S_No=@OPBIdCount))
				
				Begin
					Delete From  OBD From Bean.OpeningBalanceDetail As OBD 
					Inner join Bean.OpeningBalance As OB On OB.Id=OBD.OpeningBalanceId
					Where OB.CompanyId=@CompanyId And OB.Id=@OpeningBalanceId 
					And OBD.Id=(Select OPDId From @Temp Where S_No=@OPBIdCount)
				End

				Set @OPBIdCount=@OPBIdCount+1

			End

		END

		Commit Transaction

	End Try

	Begin Catch

		RollBack
		Print 'In Catch Block';
		Throw;

	End Catch

End
GO

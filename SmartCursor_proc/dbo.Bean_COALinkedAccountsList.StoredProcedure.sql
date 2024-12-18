USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_COALinkedAccountsList]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   Procedure [dbo].[Bean_COALinkedAccountsList]  
@CompanyId BigInt , 
@userName nvarchar(100)
As  
Begin  
 Declare @HRModuleId bigint = (select Id from common.ModuleMaster where Name='HR Cursor')  
 Declare @BCModuleId bigint = (select Id from common.ModuleMaster where Name='Bean Cursor')  
 Declare @WFModuleId bigint = (select Id from common.ModuleMaster where Name='Workflow Cursor')  
 Declare @LinkedAcc_Rec Table (Id BigInt,[Cursor] Nvarchar(250),Subsection Nvarchar(250),Feature Nvarchar(250),[Feature Name] Nvarchar(250),[Bean Cursor COA Name] Nvarchar(250),[Bean Cursor Account Type] Nvarchar(250),CompanyId BigInt)  
    
 Insert into @LinkedAcc_Rec 
 

        Select COAID,[Cursor],Subsection,Feature,[Feature Name],A.[Bean Cursor COA Name],[Bean Cursor Account Type],@CompanyId From  
        (  
        Select Coa.Id as COAID,'Admin' AS [Cursor],'Workflow Cursor > Incidental Setups' As Subsection, 'Incidentals' as 'Feature', I.Code [Feature Name], COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
        From Bean.Item I  
        Inner Join Bean.chartofaccount COA ON COA.Id=I.CoaId   
        Inner Join Bean.AccountType A ON A.Id= COA.AccountTypeId   
		
        Where I.CompanyId=@CompanyId   
                and I.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @WFModuleId and Status=1)  
                and I.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @BCModuleId and Status=1)  
                And I.IsIncidental = 1 And I.IsExternalData=1  And COA.IsLinkedAccount = 1 --and (COA.SubsidaryCompanyid is null or COA.SubsidaryCompanyId in (CUD.ServiceEntityId))
          
        Union All  
          
        Select Coa.Id as COAID,'Admin' AS [Cursor],'Client or Workflow Cursor' As Subsection,'Service' as 'Feature', S.Name [Feature Name], COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
        From Common.Service S   
        Inner Join Bean.chartofaccount COA ON COA.Id=S.CoaId   
        Inner Join Bean.AccountType A ON A.Id= COA.AccountTypeId   
        Inner Join Bean.Item I ON I.DocumentId=S.Id   
		
        Where I.CompanyId=@CompanyId   
                and S.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @WFModuleId and Status=1)  
                and S.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @BCModuleId and Status=1)  
                And I.IsIncidental is NULL  And I.IsExternalData=1  And COA.IsLinkedAccount = 1 --and (COA.SubsidaryCompanyid is null or COA.SubsidaryCompanyId in (CUD.ServiceEntityId))
          
        Union All  
          
        Select  Coa.Id as COAID,'HR' AS [Cursor],'Payroll' As Subsection,'Pay Component' as 'Feature', P.Name [Feature Name], COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
        From HR.Paycomponent P   
        Inner Join Bean.ChartOfAccount COA ON COA.Id=P.CoaId  
        Inner Join Bean.AccountType A ON A.Id=COA.AccountTypeId  
		
        Where P.CompanyId = @CompanyId   
                and P.CompanyId  in (select CompanyId from Common.CompanyModule where (ModuleId = @HRModuleId and Status=1))  
                and P.CompanyId in  (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1)) And COA.IsLinkedAccount = 1
				--and (COA.SubsidaryCompanyid is null or COA.SubsidaryCompanyId in (CUD.ServiceEntityId))  
								
			Union All
		
		    Select  Coa.Id as COAID,'WF' AS [Cursor],'Workflow Cursor > Incidental Setups' As Subsection, 'Incidentals' as 'Feature', I.Item [Feature Name], COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
        From WorkFlow.IncidentalClaimItem I  
        Inner Join Bean.chartofaccount COA ON COA.Id=I.CoaId   
        Inner Join Bean.AccountType A ON A.Id= COA.AccountTypeId   
        Where I.CompanyId=@CompanyId   
                and I.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @WFModuleId and Status=1)  
                and I.CompanyId in (select CompanyId from Common.CompanyModule where ModuleId = @BCModuleId and Status=1)  
                and COA.IsLinkedAccount = 1 

        Union All  
          
        Select  Coa.Id as COAID,'HR' AS [Cursor],'HR Cursor > Claim Setup' As Subsection,'Claim Item' as 'Feature', I.ItemName [Feature Name], COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
        From HR.ClaimItem I  
        Inner Join Bean.ChartOfAccount COA ON COA.Id=I.CoaId  
        Inner Join Bean.AccountType A ON A.Id=COA.AccountTypeId  
		
        Where I.CompanyId = @CompanyId   
                and I.CompanyId  in (select CompanyId from Common.CompanyModule where (ModuleId = @HRModuleId and Status=1))  
                and I.CompanyId in  (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1))
				 And COA.IsLinkedAccount = 1--and (COA.SubsidaryCompanyid is null or COA.SubsidaryCompanyId in (CUD.ServiceEntityId))
				) A  

    --Select [Cursor],Subsection,Feature ,[Feature Name] ,[Bean Cursor COA Name] ,[Bean Cursor Account Type]  From @LinkedAcc_Rec  
  --Union All  
  Insert into @LinkedAcc_Rec 
  Select COAID,[Cursor],Subsection,Feature,[Feature Name],B.[Bean Cursor COA Name],[Bean Cursor Account Type],@CompanyId From
  (
  
  Select Distinct Coa.Id as COAID,Case When A.Name In ('Cash and bank balances','Other current liabilities','Revenue') Then 'Admin'  
     When A.Name='Other income' And COA.Name='Registered Office Address' Then 'Admin'  
     When A.Name='Staff cost' And COA.Name='Training - Course Fees' Then 'Admin'  
     When A.Name='Other current assets' Then 'HR'  
    Else 'Bean'  
    End AS [Cursor],  
    Case When A.Name='Cash and bank balances' Then 'Companies > Bank Account'   
      When A.Name in ('Exchange gain/loss','Other payables','Other receivables','Other receivables','Rounding','Tax payable','Trade payables','Trade receivables') Then 'Settings'  
      When A.Name='Operating expenses' And COA.Name in ('Bank charges','Doubtful debt expense') Then 'Settings'  
      When A.Name='Other current assets' Then 'Payroll'  
      When A.Name='Other current liabilities' Then 'HR Cursor > Settings > Default Claim Processing'  
      When A.Name='Other income' And COA.Name='Registered Office Address' Then 'Client or Workflow Cursor'  
      When A.Name='Revenue' And COA.Name<>'Revenue' Then 'Client or Workflow Cursor'  
      When A.Name='System' And COA.Name<>'Opening balance' Then 'Settings'  
      When A.Name='Staff cost' And COA.Name='Training - Course Fees' Then 'Client or Workflow Cursor'
	  When COA.IsLinkedAccount=1 and COA.Name like'%Revaluation%' Then 'Revaluation'  
      Else Null End As Subsection,  
      Case When A.Name in ('Cash and bank balances','Exchange gain/loss','Intercompany clearing','Operating expenses') Then 'Linked Accounts'  
     When A.Name='Other current assets' Then 'Pay Component'  
     When A.Name='Other income' And COA.Name='Registered Office Address' Then 'Service'  
     When A.Name='Revenue' Then 'Service'  
     When A.Name='Staff cost' And COA.Name='Training - Course Fees' Then 'Service'  
     Else 'Linked Accounts' End as 'Feature',  
      Case When A.Name='Exchange gain/loss' And COA.Name='Exchange gain/loss - Realised' Then 'Exchange Gain/Loss (Realised)'  
     When A.Name='Exchange gain/loss' And COA.Name='Exchange gain/loss - Unrealised' Then 'Exchange Gain/Loss (Unrealised)'  
     When A.Name='Intercompany clearing' Then 'System Linked Accounts - Intercompany clearing accounts'  
     When A.Name='Operating expenses' And COA.Name='Bank charges' Then 'Receipt (Bank Charges)'  
     When A.Name='Operating expenses' And COA.Name='Doubtful debt expense' Then 'Debt Provision'  
     When A.Name='Other current assets' Then 'Bean Cursor Linked Accounts - Claim Deduction (Other Ded)'  
     When A.Name='Other current liabilities' Then 'Bean Cursor Linked Accounts - Claims include as Payroll Components'  
     When A.Name='Other payables' Then 'Bill/Payroll Bill/Credit Memo (Nature - Others)'  
     When A.Name='Other receivables' And COA.Name='Other receivables' Then 'Invoice/Debit Note/Credit Note (Nature - Others)Receipt - (OR) Excess Paid by Client'  
     When A.Name='Other receivables' And COA.Name='Debt provision (OR)' Then 'Debt Provision (Nature - Others)'  
     When A.Name='Retained earnings' And COA.Name='Retained earnings' Then 'System Linked Accounts (Default)'  
     When A.Name='Rounding' Then 'Rounding'   
     When A.Name='System' And COA.Name='Clearing - Receipts' Then 'Receipt (When bank receipt currency differs from receipt application currency)'  
     When A.Name='System' And COA.Name='Clearing - Transfers' Then 'Transfer (When deposit currency differs from withdrawal currency)'  
     When A.Name='System' And COA.Name='Clearing - Payments' Then 'Payment (When bank payment currency differs from payment application currency)'  
     When A.Name='System' And COA.Name='Opening balance' Then 'System Linked Accounts (Default)'  
     When A.Name='Tax payable' And COA.Name='Tax payable (GST)' Then 'GST (Input/Output Tax)'  
     When A.Name='Trade payables' And COA.Name='Trade payables' Then 'Bill/Payroll Bill/Credit Memo (Nature - Trade)'  
     When A.Name='Trade receivables' And COA.Name='Trade receivables' Then 'Invoice/Debit Note/Credit Note (Nature - Trade)Receipt - (TR) Excess Paid by Client'  
     When A.Name='Trade receivables' And COA.Name='Debt provision (TR)' Then 'Debt Provision (Nature - Trade)'  
	 
     Else 'Bean Cursor Linked Accounts'  
     End As [Feature Name],  
      COA.Name [Bean Cursor COA Name], A.Name [Bean Cursor Account Type]   
  From  Bean.ChartOfAccount COA   
  Inner Join Bean.AccountType A ON A.Id=COA.AccountTypeId  
  	Inner Join Common.Company C ON COA.CompanyId = C.ParentId and C.ParentId=@companyId
	Inner Join Common.CompanyUser CU ON C.ParentId = CU.CompanyId
	Inner Join Common.CompanyUserDetail CUD ON CU.Id = CUD.CompanyUserId and C.Id = CUD.ServiceEntityId
  Where COA.CompanyId = @CompanyId   
   and COA.CompanyId in  (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1))   
   AND COA.IsLinkedAccount=1  and COA.Id Not In(Select Id from @LinkedAcc_Rec) 
   And CU.Username = @userName And COA.IsLinkedAccount = 1 and (COA.SubsidaryCompanyid is null or COA.SubsidaryCompanyId in (CUD.ServiceEntityId))
        ) B  
		--Where B.COAID Not In(Select Distinct COAID from @LinkedAcc_Rec)
  
  Select [Cursor],Subsection,Feature ,[Feature Name] ,[Bean Cursor COA Name] ,[Bean Cursor Account Type]  From @LinkedAcc_Rec  
End

GO

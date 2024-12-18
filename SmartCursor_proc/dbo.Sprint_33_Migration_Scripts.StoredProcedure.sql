USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sprint_33_Migration_Scripts]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Sprint_33_Migration_Scripts]
@CompanyId bigint
 AS 
 Begin

  exec Bean_SummeryForAllEntity @CompanyId
--exec Sprint_33_Migration_Scripts 19
		if not exists(select * from Common.GenericTemplate where CompanyId=@CompanyId and TemplateTypeId=(select Id from Common.TemplateType where Name='Invoice' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')))
		Begin
		insert Common.GenericTemplate values(NewId(),@CompanyId,(select Id from Common.TemplateType where Name='Invoice' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')),N'Invoice',N'Invoice',N'<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;       margin: auto;"><table style="dispalay:table;border-collapse:collapse;"><tbody><img style="width:200px;padding-top: 30px;" src="https://precursor.blob.core.windows.net/pdfcontainer/smartcursors-logo--whit8e.png" /></tbody></table><table style="width: 100%; margin-bottom: 20px;" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align: left; width: 56%; font-family: Calibri; padding: 5px;"><strong>{{Entity.Entityname}} &nbsp;</strong><br> {{Entity.MailingAddress}}                                                        
								
								<br/> {{Entity.RegisteredAddress}} &nbsp;                                                       
							
							</td><td style="width: 44%; text-align: left; font-family: Calibri;"><h2 style="margin-bottom: -15px; padding:5px;"><strong>TAX INVOICE </strong></h2><br/><span style="display: inline-block; padding-bottom: 4px; padding: 5px;"><strong>{{Company.CompanyName}}</strong></span><br><span style="display: inline-block; padding-bottom: 4px  padding: 10px;"><strong style="padding: 5px;">UEN {{Company.IdentificationType}}</strong></span><br><span style="display: inline-block; padding-bottom: 10px;  padding: 5px;"><strong> GST Reg. No.{{Company.RegistrationNo}}</strong></span><br><span style="width: 130px; display: inline-block;  padding: 5px;"><strong>Invoice Number </strong></span> : &nbsp; {{Invoice.DocNo}}                                                                                                                     
											
											<br><span style="width: 134px; display: inline-block;  padding: 5px;"><strong>Invoice Date </strong></span>: &nbsp; {{Invoice.DocDate}}                                                                                                                            
												
												<br><span style="width: 131px; display: inline-block;  padding: 5px;"><strong>Due Date</strong></span> : &nbsp; {{Invoice.DueDate}}                                                                                                                                          
												
												</td></tr><tr><td><p style="font-family: Calibri;"><strong>Attn :</strong>{{Contact.ContactSalutation}} {{Contact.ContactName}}</p></td></tr></tbody></table><table style="width: 100%; margin-bottom: 15px;border-collapse: collapse; border="0" cellspacing="0""><thead class="cf"><tr style=" font-family: Calibri;"><th style=" color:white;padding: 5px !important;font-family: Calibri;font-size:18px;text-align:left;color: #000000;background-color: #dcdcdc;border: 1px solid #bdbdbd;">Item Code</th><th style=" color:white;padding: 5px !important;text-align:left;font-family: Calibri;font-size:18px;color: #000000;background-color: #dcdcdc;border: 1px solid #bdbdbd;">Item Description</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-family: Calibri;font-size:18px;background-color: #dcdcdc;border: 1px solid #bdbdbd;">Quantity</th><th style=" color:white;padding: 5px !important;text-align:right;font-family: Calibri;font-size:18px;color: #000000;background-color: #dcdcdc;border: 1px solid #bdbdbd;">Unit Price</th>              {{#if IsGST}}                              
												
												<th style=" color:white;padding: 5px !important;text-align:left;font-family: Calibri;font-size:18px;color: #000000;border: 1px solid #bdbdbd;background-color: #dcdcdc;">Tax Code</th>{{/if}}                                            
												
												<th style=" color:white;padding: 5px !important;text-align:left;font-family: Calibri;font-size:18px;color: #000000;border: 1px solid #bdbdbd;background-color: #dcdcdc;">Currency</th><th style=" color:white;padding: 5px !important;text-align:right;font-family: Calibri;font-size:18px;color: #000000;border: 1px solid #bdbdbd;background-color: #dcdcdc;">Amount</th></tr></thead><tbody>              {{#each ItemDetail}}                                                                                                                              
											
											<tr><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{ItemCode}} </td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{ItemDescription}} </td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{Quantity}} </td><td style="padding: 5px;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{UnitPrice}} </td>              {{#if IsGST}}                              
												
												<td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{TaxCode}} </td>{{/if}}                                            
												
												<td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{Currency}}</td><td style="padding: 5px;border-bottom:1px solid #000;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{Amount}}</td></tr>              {{/each}}                                                                                                                 
											
											<tr><td colspan="8" style="padding: 5px;border-bottom:1px solid #000;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;"><strong>{{Invoice.Total}}</strong></td></tr></tbody></table>            {{#if IsGST}}                       
									
									<table style="width: 100%;dispalay:table;border-collapse:collapse;"><tbody>              {{#each Invoice.TaxCode}}                                                                                                                              
											
											<tr><td>{{TaxName}} @ {{TaxRate}}% </td><td style="text-align: right;">{{SubTotal}} </td></tr>              {{/each}}                                                                                                                              
											
											<tr><td style="padding:10px 5px; font-family: Calibri;font-size:18px;"><strong>Total</strong></td><td style="text-align: right;border-top:1px solid #000"><strong>{{Invoice.SubTotal}}</strong></td></tr></tbody></table>            {{/if}}                       
									
									<table style="dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:5px;font-family: Calibri;font-size:12px;"><strong>*</strong>This is a computer generated letter and no signature is required.                                                                                                                          
												
												</td></tr></tbody></table>{{#if IsGST}}                                                           
									
									<table style="dispalay:table;border-collapse:collapse;width:100%;"><tbody><tr><td style="padding: 5px;font-family: Calibri;font-size:14px;"><strong>SGD Equivalent</strong></td></tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total amount (excluding GST): </td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.ExcludeGST}}</td></tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total GST payable:</td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.GSTPayable}}</td></tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total amount (including GST):</td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.IncludeGST}}</td></tr></tbody></table>{{/if}}                                                           
									
									<br><table style="dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:5px;"><strong>For cheque payment, crossed cheque is to be made in favour of Precursor Group Pte Ltd </strong></td></tr><tr><td style="padding:5px;">Please indicate the invoice number(s) at the back of your cheque. </td></tr><tr><td style="padding:5px;"><strong></strong></td></tr><tr><td style="padding:5px;">For TT remittance / Giro Payment, please remit to the following bank account: </td></tr><tr><td style="padding: 5px;"><strong></strong></td></tr></tbody></table><table style="width: 100%; margin-bottom: 15px;border-collapse: collapse; border="0" cellspacing="0""><tbody><tr><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:18px;border: 1px solid #bdbdbd;"><strong> SWIFT Code:</strong></td><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:14px;border: 1px solid #bdbdbd;">{{Company.SWIFTCode}}</td></tr><tr><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:18px;border: 1px solid #bdbdbd;"><strong> Beneficiary Bank Name:</strong></td><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:14px;border: 1px solid #bdbdbd;">{{Company.BankName}}</td></tr><tr><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:18px;border: 1px solid #bdbdbd;"><strong> Beneficiary Bank Address:</strong></td><td style="padding: 5px;font-family: Calibri;font-size:14px;border: 1px solid #bdbdbd;">{{Company.BankAddress}}</td></tr><tr><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;border: 1px solid #bdbdbd;"><strong> Beneficiary Account No.:</strong></td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px">{{Company.AccountNumber}}</td></tr><tr><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:18px;border: 1px solid #bdbdbd;"><strong> Beneficiary Name:</strong></td><td style="padding: 5px;width: 50%;font-family: Calibri;font-size:14px;border: 1px solid #bdbdbd;">{{Company.AccountName}}</td></tr></tbody></table></body></html>',1,1,1,10,NULL,N'madhu@kgtan.com',Getdate(),NULL,Null,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
					   END


					   
if not exists(select * from Common.GenericTemplate where CompanyId=@CompanyId and TemplateTypeId=(select Id from Common.TemplateType where Name='Credit Note' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')))
Begin
insert Common.GenericTemplate values(NewId(),@CompanyId,(select Id from Common.TemplateType where Name='Credit Note' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')),N'Credit Note',N'Credit Note',N'<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;        margin: auto;"><table style="dispalay:table;border-collapse:collapse;"><tbody><img style="width:200px;padding-top: 30px;" src="https://precursor.blob.core.windows.net/pdfcontainer/smartcursors-logo--whit8e.png" /><tr><td height="10"></td></tr></tbody></table><table style="width: 100%; margin-bottom: 20px;" border="0" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align: left; width: 56%; font-family: Calibri;"><strong>{{Entity.Entityname}}   &nbsp;</strong><br> {{Entity.RegisteredAddress}}                              
								
								
								
								<br> {{Entity.MailingAddress}}                      &nbsp;                          
								
								
								
								</td><td style="width: 44%; text-align: left; font-family: Calibri;"><h2 style="margin-bottom: -15px;"><strong>CREDIT NOTE </strong></h2><br><span style="display: inline-block; padding-bottom: 4px;"><strong>{{Company.CompanyName}}</strong></span><br><span style="display: inline-block; padding-bottom: 4px;"><strong>UEN {{Company.IdentificationType}}</strong></span><br><span style="display: inline-block; padding-bottom: 10px;"><strong> GST Reg. No.{{Company.RegistrationNo}}</strong></span><br><span style="width: 130px; display: inline-block;"><strong>Credit Note Number </strong></span> : &nbsp; {{Invoice.DocNo}}                                  
													
													
													
													<br><span style="width: 134px; display: inline-block;"><strong>Credit Note Date </strong></span>: &nbsp; {{Invoice.DocDate}}                                     
														
														
														
														<br><span style="width: 131px; display: inline-block;"><strong>Due Date</strong></span> : &nbsp; {{Invoice.DueDate}}                                
														
														
														
														</td></tr><tr><td><p style="font-family: Calibri;"><strong>Attn:</strong>{{Contact.ContactSalutation}} {{Contact.ContactName}}
															
															</p></td></tr></tbody></table><table style="width: 100%; margin-bottom: 15px;border-collapse: collapse; border="0" cellspacing="0""><thead class="cf"><tr style="background-color: #dcdcdc; font-family: Calibri;"><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Credit Note</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Currency</th><th style=" color:white;padding: 5px !important;text-align:right;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Amount</th></tr></thead><tbody>              {{#each ItemDetail}}                             
													
													
													
													<tr><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">{{ItemCode}} </td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">{{Currency}}</td><td style="padding: 5px;border-bottom:1px solid #000;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">{{Amount}}</td></tr> {{/each}}               
													
													
													
													<tr><td colspan="3" style="padding: 5px;border-bottom:1px solid #000;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;"><strong>{{Invoice.Total}}</strong></td></tr></tbody></table>            {{#if IsGST}}            
											
											
											
											<table style="width: 100%;dispalay:table;border-collapse:collapse;"><tbody>              {{#each Invoice.TaxCode}}                             
													
													
													
													<tr><td>{{TaxName}} @ {{TaxRate}}% </td><td style="text-align: right;">{{SubTotal}} </td></tr>              {{/each}}                             
													
													
													
													<tr><td style="padding:10px 5px;"><strong>Total</strong></td><td style="text-align: right;border-top:1px solid #000"><strong>{{Invoice.SubTotal}}</strong></td></tr></tbody></table>            {{/if}}            
											
											
											
											<table style="dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:5px;font-family: Calibri;font-size:12px;"><b>*</b><i>This is a computer generated letter and no signature is required.</i></td></tr></tbody></table><table style="dispalay:table;border-collapse:collapse;width:100%;"><tbody><tr><td style="padding:5px;color: #000000;"></td></tr>{{#if IsGST}}              
													
													
													
													<tr><td style="padding: 5px;"><strong>SGD Equivalent</strong></td></tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total amount (excluding GST): </td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.ExcludeGST}}</td
													
													
													</tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total GST payable : </td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.GSTPayable}}</td></tr><tr><td style="padding: 5px;font-family: Calibri;font-size:12px;">Total amount (including GST):</td><td style="text-align:right;padding:5px;font-family: Calibri;font-size:12px;">{{Invoice.IncludeGST}}</td></tr></tbody></table></body>{{/if}}          
									
									
									
									</html>',1,1,1,10,NULL,N'madhu@kgtan.com',Getdate(),NULL,Null,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
			   END

			  
		if not exists(select * from Common.GenericTemplate where CompanyId=@CompanyId and TemplateTypeId=(select Id from Common.TemplateType where Name='Receipt' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')))
		Begin
		insert Common.GenericTemplate values(NewId(),@CompanyId,(select Id from Common.TemplateType where Name='Receipt' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')),N'Receipt',N'Receipt',N'<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;        margin: auto;"><table style="dispalay:table;border-collapse:collapse;"><tbody><img style="width:200px;padding-top: 30px;" src="https://precursor.blob.core.windows.net/pdfcontainer/smartcursors-logo--whit8e.png" /><tr><td height="10"></td></tr></tbody></table><table style="width: 100%; margin-bottom: 20px;" border="0" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align: left; width: 56%; font-family: Calibri;"><strong>{{Entity.Entityname}}&nbsp;</strong><br> {{Entity.MailingAddress}}                    
								<br> {{Entity.RegisteredAddress}} 
									<br> &nbsp;                 
									</td><td style="width: 44%; text-align: left; font-family: Calibri;"><h2 style="margin-bottom: -15px;"><strong>RECEIPT</strong></h2><br><span style="display: inline-block; padding-bottom: 4px;"><strong>{{Company.CompanyName}}</strong></span><br><span style="display: inline-block; padding-bottom: 4px;"><strong>UEN {{Company.IdentificationType}}</strong></span><br><span style="display: inline-block; padding-bottom: 10px;"><strong> GST Reg. No.{{Company.RegistrationNo}}</strong></span><br><span style="width: 130px; display: inline-block;"><strong>Receipt Number </strong></span> : &nbsp; {{receiptModel.ReceiptReferenceNumber}}                    
														<br><span style="width: 134px; display: inline-block;"><strong>Receipt Date </strong></span>: &nbsp; {{receiptModel.DocDate}}                    
															<br></td></tr><tr><td><p style="font-family: Calibri;"><strong>Attn:</strong> {{Contact.ContactSalutation}}{{Contact.ContactName}}</p></td></tr></tbody></table><span>We thank you for the payment made as follows:</span><br/><span>Payment Mode</span>&nbsp;&nbsp;&nbsp;{{receiptModel.ModeOfReceipt}}
												<br/><span>Payment Amount</span>&nbsp;&nbsp;{{receiptModel.BankReceiptCurrency}}&nbsp;&nbsp;{{receiptModel.BankReceiptAmount}}
												<br/><br/><table style="width: 100%; margin-bottom: 15px;border-collapse: collapse; border="0" cellspacing="0""><thead class="cf"><tr style="background-color: #dcdcdc; font-family: Calibri;"><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Doc Type</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Doc No</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Currency</th><th style=" color:white;padding: 5px !important;text-align:right;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Doc Total</th><th style=" color:white;padding: 5px !important;text-align:right;color: #000000;border: 1px solid #bdbdbd;font-family: Calibri;font-size:18px;">Payment Amount</th></tr></thead><tbody>              {{#each BankReceiptForApplicationDetail}}               
														<tr><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{DocType}} </td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{DocNo}}</td><td style="padding: 5px;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{DocCurrency}}</td><td style="padding: 5px;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{DocTotal}}</td><td style="padding: 5px;text-align: right;border: 1px solid #bdbdbd;font-family: Calibri;font-size:14px;">{{Amount}}</td></tr>                           {{/each}}            
													</tbody></table><table style="width: 100%;dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:10px 5px;"><strong>Total</strong></td><td style="text-align: right;padding:10px 5px;"><strong>{{TotalReceiptApplicationAmount}}</strong></td></tr></tbody></table><table style="dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:5px;font-family: Calibri;font-size:12px;"><b>*</b><i>This is a computer generated letter and no signature is required.</i></td></tr></tbody></table></body></html>',1,1,1,10,NULL,N'madhu@kgtan.com',Getdate(),NULL,Null,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
					   END
		   		  
		if not exists(select * from Common.GenericTemplate where CompanyId=@CompanyId and TemplateTypeId=(select Id from Common.TemplateType where Name='Statement Of Account' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')))
		Begin
		insert Common.GenericTemplate values(NewId(),@CompanyId,(select Id from Common.TemplateType where Name='Statement Of Account' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')),N'Statement Of Account',N'Statement Of Account',N'<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;       margin: auto;"><table style="width:100%;display: table; border-collapse: collapse;border-spacing: 2px;"><tbody><tr><td><img src="https://precursor.blob.core.windows.net/pdfcontainer/smartcursors-logo--whit8e.png" style="width:200px;margin: 15px 0 15px"></td></tr><tr><td style="width: 65%;"></td><td style="width: 35%;"><h2 style="margin-bottom:10px;">Statement of Account</h2><p><span style="font-weight: bold;">Statement Date</span>:{{StatementDate}}
								
								
								</p></td></tr><tr><td style="width: 35%;"></td></tr></tbody></table><table style="width: 100%; margin-bottom: 20px;" cellspacing="0" cellpadding="0"><tbody><tr><td style="text-align: left; width: 56%; font-family: Calibri; padding: 5px;"><strong>{{Entity.Entityname}}</strong> &nbsp;
						
						
							
							
							</td></tr><tr><td style="padding: 5px;"> {{Entity.MailingAddress}}</td></tr><tr><td style="padding: 5px;">{{Entity.RegisteredAddress}} </td></tr><br/></td></tr><tr><td><p style="font-family: Calibri; padding: 5px;">Attn:{{Contact.ContactSalutation}} {{Contact.ContactName}}</p></td></tr></tbody></table><table style="width:100%;display: table; border-collapse: collapse;border-spacing: 2px;"><td style="padding-bottom: 15px;">Dear Sir/Madam,</td></tr><tr><td style="padding-bottom: 15px;">Thank you for your support in engaging our services for your esteemed Company.</td></tr><tr><td style="padding-bottom: 15px;">We are pleased to append the Statement of Account for your reference as follow:</td></tr></table><table style="width: 100%; margin-bottom: 15px;" border="1" cellspacing="0" cellpadding="0"><thead class="cf" style="border-top: 1px solid #bdbdbd;border-bottom: 1px solid #bdbdbd;"><tr style="background-color: #dcdcdc; font-family: Calibri;"><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Doc Date</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Doc Type</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Doc No</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Currency</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Doc Total</th><th style=" color:white;padding: 5px !important;text-align:left;color: #000000;font-size:18px;">Doc Balance</th></tr></thead>
         {{#each SoaDetail}}
         
	
	
		
		
		<tbody><tr><td style="padding: 5px;font-size:14px;">{{DocDate}} </td><td style="padding: 5px;font-size:14px;">{{DocType}} </td><td style="padding: 5px;font-size:14px;">{{DocNo}} </td><td style="padding: 5px;font-size:14px;">{{Currency}} </td><td style="padding: 5px;border-bottom:1px solid #000;text-align: right;font-size:14px;">{{DocumentTotal}} </td><td style="padding: 5px;border-bottom:1px solid #000;text-align: right;font-size:14px;">{{DocBalance}} </td>
               {{/each}} 
            
		
		
			
			
			</tr></tbody></table><table style="width: 38%; margin-bottom: 15px; float:right;" cellspacing="0" cellpadding="0">
         {{#each OutstandingTotal}}
         
	
	
		
		
		<tbody><tr><td style="padding: 5px; width: 25%">{{Currency}} </td><td style="padding: 5px;text-align: right; width: 25%">{{SubTotal}}</td>
               {{/each}} 
            
		
		
			
			
			</tr></tbody></table><table style="width: 100%"><tbody><tr>Total Outstanding Balance</tr></tbody></table><br/><br/><table style="dispalay:table;border-collapse:collapse;"><tbody><tr><td style="padding:5px; font-family: Calibri; font-size:12px;"><i><strong>*</strong>This is a computer generated letter and no signature is required.
					
					
					</i></td></tr></tbody></table><table style="dispalay:table;border-collapse:collapse;"><tbody><tr><p>       For cheque payment, crossed cheque is to be made in favour of Precursor Group Pte Ltd  							
               </p></tr><tr><p>       Please indicate the invoice number(s) at the back of your cheque.					
               </p></tr><br/><tr><p>For TT remittance / Giro Payment, please remit to the following bank account:						</p></tr></table><table style="width: 100%; margin-bottom: 15px;" border="1" cellspacing="0" cellpadding="0"><tbody><tr><td style="padding: 5px;"><strong> SWIFT Code:</strong></td><td style="padding: 5px;"></td></tr><tr><td style="padding: 5px;"><strong> Beneficiary Bank Name:</strong></td><td style="padding: 5px;"></td></tr><tr><td style="padding: 5px;"><strong> Beneficiary Bank Address:</strong></td><td style="padding: 5px;"></td></tr><tr><td style="padding: 5px;"><strong> Beneficiary Account No.:</strong></td><td style="padding: 5px;"></td></tr><tr><td style="padding: 5px;"><strong> Beneficiary Name:</strong></td><td style="padding: 5px;"></td></tr></tbody></table><table><tr><p>Please feel free to contact us should you require any assistance.					</p><p>
               We look forward to a long term working relationship with you.					
            </p></tr><tr><p style="padding-top:30px;">Yours Sincerely,</p></tr><tr><p>Business Process Outsourcing Group</p></tr></table></body></html>',1,1,1,10,NULL,N'madhu@kgtan.com',Getdate(),NULL,Null,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)

		END

		--Invoice
		--DECLARE @CompanyId Bigint = 292;
		Update Auth.RolePermissionsNew set Permissions='{"Name":"Invoices","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"AddCreditNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"AddDoubtfulDebt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"AddReceipt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewCreditNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDoubtfulDebt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewReceipt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Invoices')

		Update Auth.UserPermissionNew set Permissions='{"Name":"Invoices","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"AddCreditNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"AddDoubtfulDebt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"AddReceipt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewCreditNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDoubtfulDebt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewReceipt","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Invoices')


		--Credit Note
		Update Auth.RolePermissionsNew set Permissions='{"Name":"Credit Notes","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"ViewInvoice","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDebitNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Credit Notes')

		Update Auth.UserPermissionNew set Permissions='{"Name":"Credit Notes","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"ViewInvoice","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDebitNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Credit Notes')

       	--Receipts 
		Update Auth.RolePermissionsNew set Permissions='{"Name":"Receipts","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"ViewInvoice","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDebitNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Receipts')

		Update Auth.UserPermissionNew set Permissions='{"Name":"Receipts","GroupName":"Customers","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"ViewInvoice","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true},{"Name":"ViewDebitNote","IsApplicable":false,"IsChecked":true,"IsMainActions":false,"IsReference":false,"IsFunctionality":true}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Receipts')
		
		--SOA 
		Update Auth.RolePermissionsNew set Permissions='{"Name":"Entities","GroupName":"List","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Add","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Edit","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Disable","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":true,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":true,"IsChecked":true,"IsReference":false}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Entities')

		Update Auth.UserPermissionNew set Permissions='{"Name":"Entities","GroupName":"List","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Add","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Edit","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Disable","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Email","IsApplicable":true,"IsMainActions":false,"IsFunctionality":true,"IsChecked":true,"IsReference":false},{"Name":"Download","IsApplicable":true,"IsMainActions":false,"IsFunctionality":true,"IsChecked":true,"IsReference":false}],"Tabs":[]}' 
		Where ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@CompanyId and ModuleMasterId=4 and Heading='Entities')


		IF NOT EXISTS(select Id from Common.GenericTemplate where  Name='Bean Invoice Email' and CompanyId=@CompanyId )
		BEGIN
		Insert into Common.GenericTemplate values (NEWID(),@CompanyId,(select Id from Common.TemplateType where Name='Bean Invoice Email' and CompanyId=0 and ModuleMasterId=4),'Bean Invoice Email','Bean Invoice Email','<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;
      margin: auto;"><span>Dear {{Contact.ContactName}}</span><br/><br/><span>Please find your attached Invoice. We appreciate your prompt payment.</span><br/><br/><table style="width: 100%; margin-bottom: 20px; cellspacing="0"; cellpadding="0""><tbody><tr ><td style="width:44% align-lign:left padding-botton:4px"><span><strong>Invoice Number:</strong>
           {{Invoice.DocNo}}</span><br/><span><strong>Invoice Date:</strong>
           {{Invoice.DocDate}}</span><br/><span><strong>Amount Due:</strong>
           {{InvoiceAmountDue}}</span><br/><span><strong>Due Date:</strong>
           {{Invoice.DueDate}}</span></td><tr><td style="padding:10px 5px;"><strong>Best Regards,</strong><br/><span>{{UserName}}</span></td></tr></tr></tbody></table></body></html>',1,1,1,1,null,'madhu@kgtan.com',GETDATE(),null,null,null,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
		END




		IF NOT EXISTS(select Id from Common.GenericTemplate where  Name='Bean Credit Note Email' and CompanyId=@CompanyId )
		BEGIN
		Insert into Common.GenericTemplate values (NEWID(),@CompanyId,(select Id from Common.TemplateType where Name='Bean Credit Note Email' and CompanyId=0 and ModuleMasterId=4),'Bean Credit Note Email','Credit Note Email','<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;
      margin: auto;"><span>Dear {{Contact.ContactName}}</span><br/><br/><span>Please find your attached Credit Note. We appreciate your prompt payment.</span><br/><br/><table style="width: 100%; margin-bottom: 20px; cellspacing="0"; cellpadding="0""><tbody><tr ><td style="width:44% align-lign:left padding-botton:4px"><span><strong>Invoice Number:</strong>
           {{Invoice.DocNo}}</span><br/><span><strong>Invoice Date:</strong>
           {{Invoice.DocDate}}</span><br/><span><strong>Amount:</strong>
           {{Invoice.SubTotal}}</span><br/><span><strong>Due Date:</strong>
           {{Invoice.DueDate}}</span></td><tr><td style="padding:10px 5px;"><strong>Best Regards,</strong><br/><span>{{UserName}}</span></td></tr></tr></tbody></table></body></html>',1,1,1,1,null,'madhu@kgtan.com',GETDATE(),null,null,null,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
		END


		IF NOT EXISTS(select Id from Common.GenericTemplate where  Name='Bean Receipt Email' and CompanyId=@CompanyId )
		BEGIN
		Insert into Common.GenericTemplate values (NEWID(),@CompanyId,(select Id from Common.TemplateType where Name='Bean Receipt Email' and CompanyId=0 and ModuleMasterId=4),'Bean Receipt Email','Bean Receipt Email','<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;
			  margin: auto;"><span>Dear {{Contact.ContactName}}</span><br/><br/><span>Please find your attached Receipt. We appreciate your prompt payment.</span><br/><br/><table style="width: 100%; margin-bottom: 20px; cellspacing="0"; cellpadding="0""><tbody><tr ><td style="width:44% align-lign:left padding-botton:4px"><span><strong>Receipt Number : </strong>
				   {{receiptModel.ReceiptReferenceNumber}}</span><br/><span><strong>Receipt Date : </strong>
				   {{receiptModel.DocDate}}</span><br/><span><strong>Amount : </strong>
				   {{receiptModel.BankReceiptAmount}}</span><br/></td><tr><td style="padding:10px 5px;"><strong>Best Regards,</strong><br/><span>{{UserName}}</span></td></tr></tr></tbody></table></body></html>',1,1,1,1,null,'madhu@kgtan.com',GETDATE(),null,null,null,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)

		 END


if not exists(select * from Common.GenericTemplate where CompanyId=@CompanyId and TemplateTypeId=(select Id from Common.TemplateType where Name='SOA Email' and CompanyId=0 and ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor')))
Begin
Insert into Common.GenericTemplate values (NEWID(),@CompanyId,(select Id from Common.TemplateType where Name='SOA Email' and CompanyId=0 and ModuleMasterId=4),'SOA Email','SOA Email','<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head><body style="font-family:Arial, Helvetica, sans-serif;font-size:14px; width: 900px;        margin: auto;"><span>Dear {{Contact.ContactName}}</span><br/><br/><span>Please find your attached Statement Of Account . We appreciate your prompt payment.</span><br/><br/><table style="width: 100%; margin-bottom: 20px; cellspacing="0"; cellpadding="0""><tbody><tr ><td style="width:44% align-lign:left padding-botton:4px"><span><strong>Entity Name : </strong>             {{Entity.Entityname}}</span><br/><span><strong>Outstanding Balance : </strong>             <table style="width: 38%; margin-bottom: 15px; float:right;" cellspacing="0" cellpadding="0">          {{#each OutstandingTotal}}              
	<tbody><tr><td style="padding: 5px; width: 25%">{{Currency}} </td><td style="padding: 5px;text-align: right; width: 25%">{{SubTotal}}</td>                {{/each}}                    
		</tr></tbody></table></span><br/><span><br/></td><tr><td style="padding:10px 5px;"><strong>Best Regards,</strong><br/><span>{{UserName}}</span></td></tr></tr></tbody></table></body></html>',1,1,1,1,null,'madhu@kgtan.com',GETDATE(),null,null,null,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL)
END

		 
--create Procedure Bean_SummeryForAllEntity @CompanyId bigint
--As
--Begin
----// Declaring temp Variable To Store Inner Stored Procedure Result
--Declare @Entity Table (Billing Money,PaidAmount Money,UnpaidAmount Money)
----// Declaring variables
--Declare @EntityId Uniqueidentifier
----// Declare Cursor To Pass All Company Customer Entity Id's One by one
--Declare Entity_Csr Cursor For
--Select Id From Bean.Entity where IsCustomer=1 and Companyid=@CompanyId

--Open Entity_Csr
--Fetch Next From Entity_Csr Into @EntityId
--While @@FETCH_STATUS=0
--Begin
--Insert Into @Entity 

--Exec [dbo].[Bean_SoaSummaryForEntity] @CompanyId,@EntityId

--Update Bean.Entity Set CustBal=(Select UnpaidAmount From @Entity) Where Id=@EntityId And CompanyId=@CompanyId

--Delete From @Entity

--Fetch Next From Entity_Csr Into @EntityId
--End

--Close Entity_Csr
--Deallocate Entity_Csr
--End


-------------======================



--ALTER procedure [dbo].[Bean_SoaSummaryForEntity]

-- @companyId BigInt,
-- @EntityId	uniqueidentifier

--AS
--BEGIN
--	Declare @FirstAmount Money, @SecondAmount Money, @UnpaidAmount Money, @Billings money, @AsOfDate datetime
--	SET @AsOfDate =GETUTCDATE()
--	If EXISTS( Select Id from Bean.Entity where CompanyId=@companyId and Id=@EntityId)
--	BEGIN
--	Select   SUM(Billings) Billings, SUM(PaidAmt) PaidAmt, SUM(UnpaidAmt) UnpaidAmt from
--(
--	Select SUM(Billings) Billings, SUM(PaidAmt) PaidAmt, 0 as UnpaidAmt From
--	(
--		select (firstAmount-secondAmount) as Billings ,(CSAmt+RECAmt) as PaidAmt
--	From 
--	(
--		Select 
--			CASE WHEN J.DocType in ('Invoice','Debit Note','Cash Sale') AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' then 
--			Case When JD.BaseCurrency=JD.DocCurrency Then  SUM(COALESCE(JD.BaseDebit,JD.DocDebit,0)) Else SUM(COALESCE(JD.BaseDebit,0)) END
--			else 0 End as firstAmount,
--			CASE WHEN J.DocType='Credit Note' AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' then 
--			Case When JD.BaseCurrency=JD.DocCurrency Then SUM(COALESCE(JD.BaseCredit,JD.DocCredit,0)) Else SUM(COALESCE(JD.BaseCredit,0)) END 
--			else 0 End as secondAmount,
--			CASE WHEN  J.DocType='Cash Sale' AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' THEN 
--			Case When JD.BaseCurrency=JD.DocCurrency Then SUM(COALESCE(JD.BaseDebit,JD.DocDebit,0)) Else SUM(COALESCE(JD.BaseDebit,0)) END
--			else 0 END as CSAmt,
--			CASE WHEN J.DocType='Receipt'  AND COA.Name In ('Trade receivables','Other receivables')  
--			THEN Case When JD.BaseCurrency=JD.DocCurrency Then SUM(COALESCE(JD.BaseCredit,JD.DocCredit,0)) Else SUM(COALESCE(JD.BaseCredit,0)) END
--			else 0 END as RECAmt,J.DocType
--		From Bean.JournalDetail JD 
--		JOIN Bean.Journal J on J.Id=JD.JournalId 
--		JOIN Bean.Entity E on JD.EntityId=E.Id
--		JOIN Bean.ChartOfAccount COA On COA.Id=JD.COAId
--		Where COA.CompanyId=@CompanyId 
--		and JD.PostingDate <= @AsOfDate
		
				

--		AND J.DocType IN ('Invoice','Debit Note','Cash Sale','Receipt','Credit Note') AND   J.DocumentState Not In ('Void','Recurring','Parked','Cancelled') AND Jd.EntiTyId=@EntityId
--		Group By J.DocumentState,J.DocType,JD.DocumentDetailId,JD.BaseCurrency,JD.DocCurrency,COA.Name
--			  Union All

--  				Select 
--			CASE WHEN I.DocType in ('Invoice') AND I.DocSubType IN ('Opening Bal') 
--			 then ISNULL(Id.BaseAmount,0) else 0 End as firstAmount,
--			 0  as secondAmount,
--			 0  as CSAmt,
--			 0  as RECAmt,I.DocType
--		From Bean.Invoice I
--        Inner Join Bean.InvoiceDetail ID ON ID.InvoiceId=I.Id
--		JOIN Common.Company E On  I.CompanyId=E.Id
--		JOIN Bean.ChartOfAccount COA On COA.Id=ID.COAId
--		Where e.Id=@CompanyId and I.DocDate <=@AsOfDate
--		And I.DocType in ('Invoice') AND I.DocSubType IN ('Opening Bal') AND I.IsOBInvoice = 1   AND I.DocumentState Not In ('Void','Recurring','Parked','Cancelled') and I.EntityId=@EntityId
		
--	) as P Where (firstAmount-secondAmount)<>0 or (CSAmt+RECAmt)<>0  
--	) AS S
--	Union All
--	--unpaid Amount // Balance Amount
--	Select 0 as Billings,0 as PaidAmt, SUM(UnpaidAmt) UnpaidAmt From 
--	(
--	Select COALESCE(REMAININGAMT,0) as UnpaidAmt
--	From 
--	(
--		Select 
--		--ISNULL(SUM(J.BalanceAmount),0) * ISNULL(J.ExchangeRate,0) as REMAININGAMT
--		Case When J.DocType IN ('Credit Note','Receipt') Then 
--			Convert(money,Concat('-',ISNULL(SUM(J.BalanceAmount),0)*J.ExchangeRate)) Else ISNULL(SUM(J.BalanceAmount),0)*J.ExchangeRate End  as  REMAININGAMT
--		From Bean.JournalDetail JD 
--		JOIN Bean.Journal J on J.Id=JD.JournalId 
--		--JOIN Common.DimEntity E on JD.ServiceEntityId=E.SourceEntityId
--		Where J.CompanyId=@CompanyId AND JD.DocType in ('Invoice','Debit Note','Receipt','Cash Sale','Debt Provision','Credit Note') AND J.DocumentState Not in ('Void', 'Fully Paid','Fully Allocated','Fully Applied','Recurring','Parked','Cancelled')  AND JD.PostingDate<=@AsOfDate AND 
--		JD.DocumentDetailId='00000000-0000-0000-0000-000000000000' and JD.EntityId=@EntityId
--		Group By J.ExchangeRate,J.DocType
--		Union All
--	Select Case When I.DocType IN ('Credit Note','Receipt') Then 
--			Convert(money,Concat('-',ISNULL(SUM(I.BalanceAmount),0)*I.ExchangeRate)) 
--			Else ISNULL(SUM(I.BalanceAmount),0)*I.ExchangeRate End  as  REMAININGAMT
--		From Bean.Invoice I
--        Inner Join Bean.InvoiceDetail ID ON ID.InvoiceId=I.Id
--		--JOIN Common.Company E On  I.ServiceCompanyId=E.Id
--		Where I.CompanyId=@CompanyId And I.DocType in ('Invoice') AND I.DocSubType IN ('Opening Bal') AND I.IsOBInvoice = 1 AND I.DocumentState Not in ('Void', 'Fully Paid','Fully Allocated','Fully Applied','Recurring','Parked','Cancelled')
--		AND I.DocDate<=@AsOfDate and I.EntityId=@EntityId
--		--AND JD.DocumentDetailId='00000000-0000-0000-0000-000000000000'
--		Group By I.ExchangeRate,I.DocType

--	) as UnpaidAmt   
--	) AS K
--	) As L
--	END
--END


END




GO

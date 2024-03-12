public class QBMap {

    /**
     * Map the SF Account data to the QB customer JSON
     * @param acc The account data that is mapped
     * @return the QB json that can be used to CRUD a customer in QBO
     */
    public static String mapAccountData(Account acc){
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        //Map given account fields
        customer.CompanyName = acc.Name;
        customer.Taxable = acc.Taxable__c;
        if(!acc.Taxable__c){
            customer.TaxExemptionReasonId = acc.Tax_Exemption_Reason__c;
            customer.ResaleNum = 'Resale';
        }        
        customer.SyncToken = acc.QB_SyncToken__c;
        customer.sparse = True;

        //Create Shipping address
        QBCustomerJSON.BillAddr shipAddy = new QBCustomerJSON.BillAddr();
        shipAddy.City = acc.ShippingCity;
        shipAddy.Line1 = acc.ShippingStreet;
        shipAddy.CountrySubDivisionCode = acc.ShippingState;
        shipAddy.PostalCode = acc.ShippingPostalCode;
        shipAddy.Country = acc.ShippingCountry;
        customer.ShipAddr = shipAddy;

        customer.PrintOnCheckName = acc.Name;
        //Create Primary Phone
        QBCustomerJSON.PrimaryPhone phone = new QBCustomerJSON.PrimaryPhone ();
        phone.FreeFormNumber = acc.Phone;
        customer.PrimaryPhone = phone;
        //customer.PrimaryEmailAddr = acc.Email; //does not have correct mapping
        customer.Job = False;
        customer.IsProject = False;
        customer.Id = acc.QB_ID__c;
        customer.DisplayName = acc.Name;

        //Create Billing Address
        QBCustomerJSON.BillAddr billAddy = new QBCustomerJSON.BillAddr();
        billAddy.City = acc.BillingCity;
        billAddy.Line1 = acc.BillingStreet;
        billAddy.CountrySubDivisionCode = acc.BillingState;
        billAddy.PostalCode = acc.BillingPostalCode;
        billAddy.Lat = String.valueOf(acc.BillingLatitude);
        billAddy.Long_x = String.valueOf(acc.BillingLongitude);
        billAddy.Country = acc.BillingCountry;
        customer.BillAddr = billAddy;

        customer.Active = True;

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');
    }

    /**
     * Map an invoice from Salesforce to QBO JSON
     * @param inv The invoice that is used for the mapping
     * @return The json String that is used for the body of the request callout 
     */
    public static String mapInvoice(Invoice__c inv, List<Invoice_Line_Item__c> ilis, String customerId){
        //Initialize invoice object
        QBInvoiceJSON invoiceObj = new QBInvoiceJSON();
        QIME_Config__mdt config = [SELECT Id, Use_Line_Item__c, QB_Product_Id__c 
                                            FROM QIME_Config__mdt 
                                            WHERE Label = 'Default'];

        invoiceObj.Id = inv.QB_Id__c;
        invoiceObj.SyncToken = inv.QB_SyncToken__c;
        invoiceObj.DueDate = inv.Due_Date__c;
        invoiceObj.AllowOnlineACHPayment = inv.Allow_Online_ACH_Payment__c;
        invoiceObj.AllowOnlineCreditCardPayment = inv.Allow_Online_CC_Payment__c;
        invoiceObj.AutoDocNumber = True;
        invoiceObj.TxnTaxDetail = new QBInvoiceJSON.TxnTaxDetail();
        // // @todo unhardcode
        // invoiceObj.TxnTaxDetail.TxnTaxCodeRef = new QBInvoiceJSON.TxnTaxCodeRef();
        // invoiceObj.TxnTaxDetail.TxnTaxCodeRef.value = '17';
        invoiceObj.TxnTaxDetail.TotalTax = inv.tax__c;
        if(String.isNotBlank(inv.name) && !inv.name.contains('X')){
            String invNumber = inv.name.replace('INV-', '');
            invoiceObj.DocNumber  = invNumber;
        }
        invoiceObj.EmailStatus = 'NotSet';
        QBInvoiceJSON.EmailAddress email = new QBInvoiceJSON.EmailAddress();
        email.Address = inv.email__c;
        invoiceObj.BillEmail = email;

        QBInvoiceJSON.CustomerRef customerRef = new QBInvoiceJSON.CustomerRef();
        customerRef.value = customerId;
        invoiceObj.CustomerRef = customerRef;
        
        //Map Memo
        QBInvoiceJSON.MemoRef memoRef = new QBInvoiceJSON.MemoRef();
        memoRef.value = inv.Memo__c;
        invoiceObj.CustomerMemo = memoRef;
        //map billing terms @todo map this based on terms
        QBInvoiceJSON.SalesTermRef sales = new QBInvoiceJSON.SalesTermRef();
        sales.value = mapTerms(inv.Terms__c);
        invoiceObj.SalesTermRef = sales;
        
        //Create Billing Address
        QBInvoiceJSON.BillAddr billAddy = new QBInvoiceJSON.BillAddr();
        billAddy.City = nullCheck(inv.Bill_City__c);
        billAddy.Line1 = nullCheck(inv.Bill_Street__c) + ' ' + nullCheck(inv.Bill_Suite__c);
        billAddy.CountrySubDivisionCode = nullCheck(inv.Bill_State__c);
        billAddy.PostalCode = nullCheck(inv.Bill_Zip__c);
        billAddy.Country = nullCheck(inv.Bill_Country__c);
        invoiceObj.BillAddr = billAddy;

        //Create Shipping Address
        QBInvoiceJSON.BillAddr shipAddy = new QBInvoiceJSON.BillAddr();

        shipAddy.City = nullCheck(inv.Ship_City__c);
        shipAddy.Line1 = nullCheck(inv.Ship_Street__c) + ' ' + nullCheck(inv.Ship_Suite__c);
        shipAddy.PostalCode = nullCheck(inv.Ship_Zip__c);
        shipAddy.CountrySubDivisionCode = nullCheck(inv.Ship_State__c);
        shipAddy.Country = nullCheck(inv.Ship_Country__c);

        invoiceObj.ShipAddr = shipAddy;


        //map sales rep and po number (Not possible to add sales rep)
        invoiceObj.CustomField = new List<QBInvoiceJSON.CustomField>();

        //Initialize line items for invoice mapping
        invoiceObj.Line = new List<QBInvoiceJSON.Line>();
        if(config.Use_Line_Item__c){
            QBInvoiceJSON.Line line = new QBInvoiceJSON.Line();
            line.Amount = inv.Subtotal__c;
            //@todo unhardcode this
            line.DetailType = 'SalesItemLineDetail';
            QBInvoiceJSON.SalesItemLineDetail detail = new QBInvoiceJSON.SalesItemLineDetail();

            QBInvoiceJSON.ItemRef itemRef = new QBInvoiceJSON.ItemRef();

            itemRef.value = config.QB_Product_Id__c;
            detail.ItemRef = itemRef;
            detail.Qty = 1.0;
            detail.TaxCodeRef = new QBInvoiceJSON.ItemRef();
            detail.TaxCodeRef.value = 'TAX';
            line.SalesItemLineDetail = detail;
            invoiceObj.Line.add(line);

        }else if(ilis != null){
            for(Invoice_Line_Item__c ili : ilis){
                QBInvoiceJSON.Line line = new QBInvoiceJSON.Line();
                //map line item fields
                if(String.isNotBlank(ili.QB_ID__c)){
                    Pattern p = Pattern.compile('([0-9]*)-([0-9])*');
                    Matcher pm = p.matcher( ili.QB_Id__c );

                    if( pm.matches() ){
                        line.Id = pm.group(2);
                    }
                }
                line.Amount = ili.Amount__c;
                line.Description = ili.Product__r.QB_Description__c;
                if(String.isNotBlank(ili.Description__c)){
                    line.Description = ili.Description__c;
                }
                //@todo unhardcode this
                line.DetailType = 'SalesItemLineDetail';
                QBInvoiceJSON.SalesItemLineDetail detail = new QBInvoiceJSON.SalesItemLineDetail();
    
                QBInvoiceJSON.ItemRef itemRef = new QBInvoiceJSON.ItemRef();
    
                itemRef.value = ili.Product__r.QB_Id__c; 
                detail.ItemRef = itemRef;
                detail.Qty = ili.Quantity__c;
                detail.UnitPrice = ili.Unit_Price__c;
                detail.TaxCodeRef = new QBInvoiceJSON.ItemRef();
                detail.TaxCodeRef.value = 'TAX';
                if(ili.taxable__c){
                    detail.TaxCodeRef.value = 'NON';
                }
                line.SalesItemLineDetail = detail;
                invoiceObj.Line.add(line);
            }
        }


        //Map Shipping fields
        QBInvoiceJSON.Line shippingLine = new QBInvoiceJSON.Line();
        shippingLine.Amount = inv.Shipping_Handling__c;
        if(inv.Shipping_Handling__c == null){
            shippingLine.Amount = 0;
        }
        shippingLine.DetailType = 'SalesItemLineDetail';
        shippingLine.SalesItemLineDetail = new QBInvoiceJSON.SalesItemLineDetail();
        shippingLine.SalesItemLineDetail.ItemRef = new QBInvoiceJSON.ItemRef();
        shippingLine.SalesItemLineDetail.ItemRef.value = 'SHIPPING_ITEM_ID';
        invoiceObj.Line.add(shippingLine);

        return JSON.serialize(invoiceObj, True).replace('"Long_x":', '"Long":');
    }

    private static String mapTerms(String term){
        if(String.isBlank(term)){
            return null;
        }
        List<QB_Terms__c> terms = [SELECT Id, QB_ID__c
                                            FROM QB_Terms__c 
                                            WHERE Name =: term];
        if(terms.size() == 0){
            throw new QBException('Please map the term id for ' + term );
        }
        return terms[0].QB_ID__c;
    }

    /**
     * Map an invoice from QBO JSON to Salesforce
     * @param inv The invoice that is used for the mapping
     * @param json Query json from QBO
     * @return The the invoice that can be crud to salesforce
     */
    public static invoiceReturn mapInvoiceData(Invoice__c inv, QBInvoiceQueryJSON json){
        List<Payment__c> payments = new List<Payment__c>();
        List<Invoice_Payment__c> inv_payments = new List<Invoice_Payment__c>();

        if(json.QueryResponse.Invoice.size() > 0){
            inv.balance_Due__c = json.QueryResponse.Invoice[0].Balance;
            for(QBInvoiceQueryJSON.Invoice invoice : json.QueryResponse.Invoice){
                for(QBInvoiceQueryJSON.LinkedTxn txn : invoice.LinkedTxn){
                    Payment__c p = new Payment__c();
                    p.qb_id__c = txn.TxnId;
                    payments.add(p);

                    Invoice_Payment__c inv_payment = new Invoice_Payment__c();
                    inv_payment.Payment__r = new Payment__c(qb_id__c = txn.TxnId);
                    inv_payment.Invoice__r = new Invoice__c(qb_Id__c = invoice.Id);
                    inv_payment.QB_Invoice_Id__c = invoice.Id;
                    inv_payment.QB_Payment_Id__c = txn.TxnId;
                    // Linked transactions have a unique id of inv id + payment id
                    inv_payment.qb_Id__c = invoice.Id + '-' + txn.TxnId;
                    inv_payments.add(inv_payment);
                }

            }
        }

        invoiceReturn returnVar = new invoiceReturn();
        returnVar.payments = payments;
        returnVar.inv = inv;
        return returnVar;
    }

        /**
     * Map an invoice from QBO JSON to Salesforce
     * @param inv The invoice that is used for the mapping
     * @param json Query json from QBO
     * @return The the invoice that can be crud to salesforce
     */
    public static List<SObject> mapInvoiceData(Invoice__c inv, List<Invoice_Line_Item__c> ilis, QBInvoiceResponseJSON json){
        List<SObject> returnList = new List<SObject>();
        // Key: QB Product Id, Value: Line Item Id
        Map<String,String> lineItemMap = new Map<String,String>();
        inv.QB_ID__c = json.Invoice.Id;
        inv.QB_SyncToken__c = json.Invoice.SyncToken;
        inv.balance_Due__c = json.Invoice.Balance;

        inv.name = 'INV-' + json.Invoice.DocNumber;

        for(QBInvoiceResponseJSON.Line ili : json.Invoice.Line){
            if(String.isNotBlank(ili?.SalesItemLineDetail?.ItemRef?.value)){
                lineItemMap.put(ili.SalesItemLineDetail.ItemRef.value, ili.Id);
            }
        }

        for(Invoice_Line_Item__c ili : ilis){
            if(lineItemMap.containsKey(ili.ItemRef_Id__c)){
                ili.QB_Id__c = lineItemMap.get(ili.ItemRef_Id__c);
            }
        }

        returnList.add(inv);
        returnList.addAll(ilis);
        return returnList;
    }

    public class invoiceReturn {
        public List<Payment__c> payments{get; set;}
        public List<Invoice_Payment__c> invoice_payments{get; set;}
        public Invoice__c inv{get;set;}
    }

    /**
     * Get the count from the query response 
     * @param countJSON The response data from a count(*) query
     * @return The count in QB for the given object
     */
    public static Integer getCount(QBQueryResponseCountJSON countJSON){
        return countJSON.QueryResponse.totalCount;
    }

    /**
     * Map invoice query data into invoices, payments, and invoice line item
     * @param invQuery The response data from invoice query
     * @return List of Invoice__c, Payment__c, Invoice_Payment__c, and Invoice_Line_Item__c
     */
    public static List<SObject> mapInvoices(QBInvoiceQueryJSON invQuery){
        List<Payment__c> payments = new List<Payment__c>();
        List<Invoice_Payment__c> inv_payments = new List<Invoice_Payment__c>();
        List<Invoice_Line_Item__c> ilis = new List<Invoice_Line_Item__c>();
        List<SObject> returnList = new List<SObject>();
        if(invQuery?.QueryResponse?.Invoice == null){
            return new List<SObject>();
        }
        for(QBInvoiceQueryJSON.Invoice invoice : invQuery?.QueryResponse?.Invoice){
            Invoice__c inv = new Invoice__c();
            Decimal subtotal = 0.0;
            inv.QB_ID__c = invoice.Id;
            inv.QB_SyncToken__c = invoice.SyncToken;
            inv.Allow_Online_ACH_Payment__c = invoice.AllowOnlineACHPayment;
            inv.Allow_Online_CC_Payment__c = invoice.AllowOnlineCreditCardPayment;
            inv.Document_Number__c = invoice.DocNumber;
            inv.name = 'INV-' + invoice.DocNumber;
            inv.Transaction_Date__c = Date.valueOf(invoice.TxnDate);
            inv.Customer_Id__c = invoice.CustomerRef?.value;
            try{
                inv.Delivery_Time__c = (DateTime)Json.deserialize('"'+invoice?.DeliveryInfo?.DeliveryTime+'"', DateTime.class);
            }catch(Exception e){
                System.debug(e);
            }

            inv.Due_Date__c = Date.valueOf(invoice.DueDate);
            inv.Total__c = invoice.TotalAmt;
            inv.Memo__c = invoice?.CustomerMemo?.value;

            inv.emails__c = invoice.BillEmail?.Address;
            inv.bcc_emails__c = invoice.BillEmailBcc?.Address;
            inv.cc_emails__c = invoice.BillEmailCc?.Address;

            inv.Balance__c = invoice.Balance;
            if(invoice?.TxnTaxDetail?.TotalTax != null){
                inv.tax__c = invoice?.TxnTaxDetail?.TotalTax;
            }
            if(String.isNotBlank(invoice.SalesTermRef?.name)){
                inv.Terms__c = invoice.SalesTermRef?.name; 
            }

            if(invoice?.LinkedTxn.size() > 0){
                for(QBInvoiceQueryJSON.LinkedTxn txn : invoice.LinkedTxn){
                    if(txn.TxnType != 'Payment'){
                        continue;
                    }
                    Payment__c p = new Payment__c();
                    p.qb_id__c = txn.TxnId;
                    payments.add(p);

                    Invoice_Payment__c inv_payment = new Invoice_Payment__c();
                    inv_payment.Payment__r = new Payment__c(qb_id__c = txn.TxnId);
                    inv_payment.Invoice__r = new Invoice__c(qb_Id__c = invoice.Id);
                    inv_payment.QB_Invoice_Id__c = invoice.Id;
                    inv_payment.QB_Payment_Id__c = txn.TxnId;
                    // Linked transactions have a unique id of inv id + payment id
                    inv_payment.qb_Id__c = invoice.Id + '-' +  txn.TxnId;
                    inv_payments.add(inv_payment);
                }
            }

            

            if(String.isNotBlank(invoice?.PrivateNote)){
                inv.Message_on_Statement__c = invoice?.PrivateNote;
            }
            Integer lineCount = 0;
            for(QBInvoiceQueryJSON.Line line_item : invoice.Line){
                Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
                Invoice__c invRef = new Invoice__c();
                invRef.QB_Id__c = invoice.Id;
                ili.QB_ID__c = invoice.Id + '-' + line_item.id;
                ili.LineNum__c = line_item.LineNum;
                ili.Amount__c = line_item.Amount;
                if(line_item?.DetailType == 'SalesItemLineDetail'){
                    ili.ItemRef_Id__c = line_item?.SalesItemLineDetail?.ItemRef?.value;
                    ili.Quantity__c = line_item?.SalesItemLineDetail?.Qty;
                    ili.Unit_Price__c = line_item?.SalesItemLineDetail?.UnitPrice;
                    ili.Description__c = line_item.Description;

                }else if(line_item?.DetailType == 'GroupLineDetail'){

                    ili.ItemRef_Id__c = line_item?.GroupLineDetail?.GroupItemRef?.value;
                    ili.Quantity__c = line_item?.GroupLineDetail?.Quantity;
                    ili.Unit_Price__c = line_item?.GroupLineDetail?.Amount;
                }
                if(String.isNotBlank(line_item?.SalesItemLineDetail?.ServiceDate)){
                    ili.Service_Date__C = Date.valueOf(line_item?.SalesItemLineDetail?.ServiceDate);
                }
                
                ili.Invoice__r = invRef;
                if(line_item?.SalesItemLineDetail?.TaxCodeRef?.value == 'TAX'){
                    ili.Taxable__c = True;
                }
                if(line_item.DetailType == 'SubTotalLineDetail'){
                    inv.Subtotal__c = line_item.Amount;
                }else{
                    lineCount ++;
                }
                if(line_item.DetailType == 'SalesItemLineDetail' && 
                    line_item?.SalesItemLineDetail?.ItemRef?.value == 'SHIPPING_ITEM_ID'){
                        inv.Shipping_Handling__c = line_item.Amount;
                }
                if(line_item.DetailType == 'SalesItemLineDetail' || 
                    line_item.DetailType == 'GroupLineDetail' ){
                    ilis.add(ili);
                }
            }
            inv.QB_Line_Count__c = lineCount;

            returnList.add(inv);
        }

        returnList.addAll(payments);
        returnList.addAll(inv_payments);
        returnList.addAll(ilis);

        return returnList;
    }

    /**
     * Map an payment from QBO JSON to Salesforce
     * @param p The payment that is used for the mapping
     * @return The the list of payments that can be crud to salesforce
     */
    public static List<Payment__c> mapPayments(QBPaymentQueryJSON json){
        List<Payment__c> paymentList = new List<Payment__c>();
        if(json?.QueryResponse?.Payment == null){
            return paymentList;
        }

        for(QBPaymentQueryJSON.Payment payment : json.QueryResponse.Payment){
            Payment__c p = new Payment__c();
            p.Amount__c = payment.TotalAmt;
            p.Transaction_Date__c = Date.valueOf(payment.TxnDate);
            if(payment?.CustomerRef?.value != null){
                p.customer_id__c = payment.CustomerRef.value;
            }
            p.unapplied_amount__c = payment.UnappliedAmt;
            p.qb_Id__c = payment.Id;
            p.qb_SyncToken__c = payment.SyncToken;
            paymentList.add(p);
        }

        return paymentList;
    }

    /**
     * Map terms to custom setting values
     * @param termsQuery query of terms from QB
     * @return List of custom setting values for upsert
     */
    public static List<QB_Terms__c> mapTermsQuery(QBTermJSON termsQuery){
        List<QB_Terms__c> terms = new List<QB_Terms__c>();
        for(QBTermJSON.Term term : termsQuery.QueryResponse.Term ){
            QB_Terms__c t = new QB_Terms__c();
            t.QB_Id__c = term.Id;
            t.Name = term.Name;
            terms.add(t);
        }

        return terms; 
    }

    /**
    * Check if string is null and return empty string
    * @param value string to check if null
    * @return string value if not null otherwise null
    */
    private static string nullCheck(String value){
        if(value == null){
            return '';
        }
        return value;
    }

}
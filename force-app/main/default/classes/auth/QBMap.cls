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
        customer.Taxable = acc.qime__Taxable__c;
        if(!acc.qime__Taxable__c){
            customer.TaxExemptionReasonId = acc.qime__Tax_Exemption_Reason__c;
            customer.ResaleNum = 'Resale';
        }        
        customer.SyncToken = acc.qime__QB_SyncToken__c;
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
        customer.Id = acc.qime__QB_ID__c;
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
    public static String mapInvoice(Invoice__c inv, List<qime__Invoice_Line_Item__c> ilis, String customerId){
        //Initialize invoice object
        QBInvoiceJSON invoiceObj = new QBInvoiceJSON();


        invoiceObj.Id = inv.qime__QB_Id__c;
        invoiceObj.SyncToken = inv.qime__QB_SyncToken__c;
        invoiceObj.DueDate = inv.qime__Due_Date__c;
        invoiceObj.AllowOnlineACHPayment = inv.qime__Allow_Online_ACH_Payment__c;
        invoiceObj.AllowOnlineCreditCardPayment = inv.qime__Allow_Online_CC_Payment__c;
        invoiceObj.AutoDocNumber = True;
        invoiceObj.TxnTaxDetail = new QBInvoiceJSON.TxnTaxDetail();
        // // @todo unhardcode
        // invoiceObj.TxnTaxDetail.TxnTaxCodeRef = new QBInvoiceJSON.TxnTaxCodeRef();
        // invoiceObj.TxnTaxDetail.TxnTaxCodeRef.value = '17';
        invoiceObj.TxnTaxDetail.TotalTax = inv.qime__tax__c;
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
        
        //Map description
        // QBInvoiceJSON.MemoRef memoRef = new QBInvoiceJSON.MemoRef();
        // memoRef.value = inv.Description__c;
        // invoiceObj.CustomerMemo = memoRef;
        //map billing terms @todo map this based on terms
        QBInvoiceJSON.SalesTermRef sales = new QBInvoiceJSON.SalesTermRef();
        sales.value = mapTerms(inv.qime__Terms__c);
        invoiceObj.SalesTermRef = sales;
        
        //Create Billing Address
        QBInvoiceJSON.BillAddr billAddy = new QBInvoiceJSON.BillAddr();
        billAddy.City = inv.qime__Bill_City__c;
        billAddy.Line1 = inv.qime__Bill_Street__c + ' ' + inv.qime__Bill_Suite__c;
        billAddy.CountrySubDivisionCode = inv.qime__Bill_State__c;
        billAddy.PostalCode = inv.qime__Bill_Zip__c;
        billAddy.Country = inv.qime__Bill_Country__c;
        invoiceObj.BillAddr = billAddy;

        //Create Shipping Address
        QBInvoiceJSON.BillAddr shipAddy = new QBInvoiceJSON.BillAddr();

        shipAddy.City = inv.qime__Ship_City__c;
        shipAddy.Line1 = inv.qime__Ship_Street__c + ' ' + inv.qime__Ship_Suite__c;
        shipAddy.PostalCode = inv.qime__Ship_Zip__c;
        shipAddy.CountrySubDivisionCode = inv.qime__Ship_State__c;
        shipAddy.Country = inv.qime__Ship_Country__c;

        invoiceObj.ShipAddr = shipAddy;

        //map sales rep and po number (Not possible to add sales rep)
        invoiceObj.CustomField = new List<QBInvoiceJSON.CustomField>();

        //Initialize line items for invoice mapping
        invoiceObj.Line = new List<QBInvoiceJSON.Line>();

        for(Invoice_Line_Item__c ili : ilis){
            QBInvoiceJSON.Line line = new QBInvoiceJSON.Line();
            //map line item fields
            
            line.Amount = ili.qime__Unit_Price__c * ili.qime__Quantity__c;
            line.Description = ili.Product__r.qime__QB_Description__c;

            //@todo unhardcode this
            line.DetailType = 'SalesItemLineDetail';
            QBInvoiceJSON.SalesItemLineDetail detail = new QBInvoiceJSON.SalesItemLineDetail();

            QBInvoiceJSON.ItemRef itemRef = new QBInvoiceJSON.ItemRef();

            itemRef.value = ili.qime__qb_Id__c; 
            detail.ItemRef = itemRef;
            detail.Qty = ili.qime__Quantity__c;
            detail.UnitPrice = ili.qime__Unit_Price__c;
            detail.TaxCodeRef = new QBInvoiceJSON.ItemRef();
            detail.TaxCodeRef.value = 'TAX';
            if(ili.qime__taxable__c){
                detail.TaxCodeRef.value = 'NON';
            }
            line.SalesItemLineDetail = detail;
            invoiceObj.Line.add(line);
        }

        //Map Shipping fields
        QBInvoiceJSON.Line shippingLine = new QBInvoiceJSON.Line();
        shippingLine.Amount = inv.qime__Shipping_Handling__c;
        if(inv.qime__Shipping_Handling__c == null){
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
        List<qime__QB_Term__c> terms = [SELECT Id, qime__QB_ID__c
                                            FROM qime__QB_Term__c 
                                            WHERE Name =: term];
        if(terms.size() == 0){
            throw new QBException('Please map the term id for ' + term );
        }
        return terms[0].qime__QB_ID__c;
    }

    /**
     * Map an invoice from QBO JSON to Salesforce
     * @param inv The invoice that is used for the mapping
     * @param json Query json from QBO
     * @return The the invoice that can be crud to salesforce
     */
    public static invoiceReturn mapInvoiceData(Invoice__c inv, QBInvoiceQueryJSON json){
        List<qime__Payment__c> payments = new List<qime__Payment__c>();
        List<qime__Invoice_Payment__c> inv_payments = new List<qime__Invoice_Payment__c>();

        if(json.QueryResponse.Invoice.size() > 0){
            inv.balance_Due__c = json.QueryResponse.Invoice[0].Balance;
            for(QBInvoiceQueryJSON.Invoice invoice : json.QueryResponse.Invoice){
                for(QBInvoiceQueryJSON.LinkedTxn txn : invoice.LinkedTxn){
                    qime__Payment__c p = new qime__Payment__c();
                    p.qb_id__c = txn.TxnId;
                    payments.add(p);

                    qime__Invoice_Payment__c inv_payment = new qime__Invoice_Payment__c();
                    inv_payment.qime__Payment__r = new qime__Payment__c(qb_id__c = txn.TxnId);
                    inv_payment.qime__Invoice__r = new qime__Invoice__c(qb_Id__c = invoice.Id);
                    inv_payment.qime__QB_Invoice_Id__c = invoice.Id;
                    inv_payment.qime__QB_Payment_Id__c = txn.TxnId;
                    // Linked transactions have a unique id of inv id + payment id
                    inv_payment.qime__qb_Id__c = invoice.Id + txn.TxnId;
                    inv_payments.add(inv_payment);
                }

            }
        }

        invoiceReturn returnVar = new invoiceReturn();
        returnVar.payments = payments;
        returnVar.inv = inv;
        return returnVar;
    }

    public class invoiceReturn {
        public List<qime__Payment__c> payments{get; set;}
        public List<qime__Invoice_Payment__c> invoice_payments{get; set;}
        public qime__Invoice__c inv{get;set;}
    }

    public static Integer getCount(QBQueryResponseCountJSON count){
        return count.QueryResponse.totalCount;
    }

    public static List<SObject> mapInvoices(QBInvoiceQueryJSON invQuery){
        List<qime__Payment__c> payments = new List<qime__Payment__c>();
        List<qime__Invoice_Payment__c> inv_payments = new List<qime__Invoice_Payment__c>();
        List<qime__Invoice_Line_Item__c> ilis = new List<qime__Invoice_Line_Item__c>();
        List<SObject> returnList = new List<SObject>();
        if(invQuery?.QueryResponse?.Invoice == null){
            return new List<SObject>();
        }
        for(QBInvoiceQueryJSON.Invoice invoice : invQuery?.QueryResponse?.Invoice){
            qime__Invoice__c inv = new qime__Invoice__c();
            Decimal subtotal = 0.0;
            inv.qime__QB_ID__c = invoice.Id;
            inv.qime__QB_SyncToken__c = invoice.SyncToken;
            inv.qime__Allow_Online_ACH_Payment__c = invoice.AllowOnlineACHPayment;
            inv.qime__Allow_Online_CC_Payment__c = invoice.AllowOnlineCreditCardPayment;
            inv.qime__Document_Number__c = invoice.DocNumber;
            inv.name = 'INV-' + invoice.DocNumber;
            inv.qime__Transaction_Date__c = Date.valueOf(invoice.TxnDate);
            inv.qime__Customer_Id__c = invoice.CustomerRef?.value;
            try{
                inv.qime__Delivery_Time__c = (DateTime)Json.deserialize('"'+invoice?.DeliveryInfo?.DeliveryTime+'"', DateTime.class);
            }catch(Exception e){
                System.debug(e);
            }

            inv.qime__Due_Date__c = Date.valueOf(invoice.DueDate);
            inv.qime__Total__c = invoice.TotalAmt;
            inv.qime__Memo__c = invoice?.CustomerMemo?.value;

            inv.qime__emails__c = invoice.BillEmail?.Address;
            inv.qime__bcc_emails__c = invoice.BillEmailBcc?.Address;
            inv.qime__cc_emails__c = invoice.BillEmailCc?.Address;

            inv.qime__Balance__c = invoice.Balance;
            if(invoice?.TxnTaxDetail?.TotalTax != null){
                inv.qime__tax__c = invoice?.TxnTaxDetail?.TotalTax;
            }
            if(String.isNotBlank(invoice.SalesTermRef?.name)){
                inv.qime__Terms__c = invoice.SalesTermRef?.name; 
            }

            if(invoice?.LinkedTxn.size() > 0){
                for(QBInvoiceQueryJSON.LinkedTxn txn : invoice.LinkedTxn){
                    if(txn.TxnType != 'Payment'){
                        continue;
                    }
                    qime__Payment__c p = new qime__Payment__c();
                    p.qb_id__c = txn.TxnId;
                    payments.add(p);

                    qime__Invoice_Payment__c inv_payment = new qime__Invoice_Payment__c();
                    inv_payment.qime__Payment__r = new qime__Payment__c(qb_id__c = txn.TxnId);
                    inv_payment.qime__Invoice__r = new qime__Invoice__c(qb_Id__c = invoice.Id);
                    inv_payment.qime__QB_Invoice_Id__c = invoice.Id;
                    inv_payment.qime__QB_Payment_Id__c = txn.TxnId;
                    // Linked transactions have a unique id of inv id + payment id
                    inv_payment.qime__qb_Id__c = invoice.Id + txn.TxnId;
                    inv_payments.add(inv_payment);
                }
            }

            

            if(String.isNotBlank(invoice?.PrivateNote)){
                inv.Message_on_Statement__c = invoice?.PrivateNote;
            }
            Integer lineCount = 0;
            for(QBInvoiceQueryJSON.Line line_item : invoice.Line){
                qime__Invoice_Line_Item__c ili = new qime__Invoice_Line_Item__c();
                qime__Invoice__c invRef = new qime__Invoice__c();
                invRef.QB_Id__c = invoice.Id;
                ili.QB_ID__c = invoice.Id + line_item.id;
                ili.qime__LineNum__c = line_item.LineNum;
                ili.qime__Amount__c = line_item.Amount;
                if(line_item?.DetailType == 'SalesItemLineDetail'){
                    ili.qime__ItemRef_Id__c = line_item?.SalesItemLineDetail?.ItemRef?.value;
                    ili.Quantity__c = line_item?.SalesItemLineDetail?.Qty;
                    ili.qime__Unit_Price__c = line_item?.SalesItemLineDetail?.UnitPrice;
                    ili.qime__Description__c = line_item.Description;

                }else if(line_item?.DetailType == 'GroupLineDetail'){

                    ili.qime__ItemRef_Id__c = line_item?.GroupLineDetail?.GroupItemRef?.value;
                    ili.qime__Quantity__c = line_item?.GroupLineDetail?.Quantity;
                    ili.qime__Unit_Price__c = line_item?.GroupLineDetail?.Amount;
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
                        inv.qime__Shipping_Handling__c = line_item.Amount;
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
    public static List<qime__Payment__c> mapPayments(QBPaymentQueryJSON json){
        List<qime__Payment__c> paymentList = new List<qime__Payment__c>();
        if(json?.QueryResponse?.Payment == null){
            return paymentList;
        }

        for(QBPaymentQueryJSON.Payment payment : json.QueryResponse.Payment){
            qime__Payment__c p = new qime__Payment__c();
            p.qime__Amount__c = payment.TotalAmt;
            p.qime__Transaction_Date__c = Date.valueOf(payment.TxnDate);
            if(payment?.CustomerRef?.value != null){
                p.qime__customer_id__c = payment.CustomerRef.value;
            }
            p.qime__unapplied_amount__c = payment.UnappliedAmt;
            p.qime__qb_Id__c = payment.Id;
            p.qime__qb_SyncToken__c = payment.SyncToken;
            paymentList.add(p);
        }

        return paymentList;
    }

    /**
     * Map terms to custom setting values
     * @param termsQuery query of terms from QB
     * @return List of custom setting values for upsert
     */
    public static List<QIME__QB_Term__c> mapTermsQuery(QBTermJSON termsQuery){
        List<qime__QB_Term__c> terms = new List<qime__QB_Term__c>();
        for(QBTermJSON.Term term : termsQuery.QueryResponse.Term ){
            qime__QB_Term__c t = new qime__QB_Term__c();
            t.qime__QB_Id__c = term.Id;
            t.Name = term.Name;
            terms.add(t);
        }

        return terms;
    }

}
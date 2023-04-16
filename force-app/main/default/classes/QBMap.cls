/**
 * Map QBO API JSON to SF Objects and vice versa
 * @author Justin Wills
 * @created 01/07/2020
 * @version v1.0
 */

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
        customer.Taxable = True;
        if(acc.Sellers_Permit__c != null){
            customer.Taxable = False;
            customer.TaxExemptionReasonId = '9';
            customer.ResaleNum = 'Resale';

        }        
        customer.SyncToken = acc.QBO_SyncToken__c;
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
        customer.Id = acc.QBO_ID__c;
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
     * Map an invoice from QBO JSON to Salesforce
     * @param inv The invoice that is used for the mapping
     * @return The the invoice that can be crud to salesforce
     */
    public static Invoice__c mapInvoiceData(Invoice__c inv, QBInvoiceQueryJSON json){
        if(json?.QueryResponse?.Invoice != null && json.QueryResponse.Invoice.size() > 0){
            inv.qime__balance_Due__c = json?.QueryResponse?.Invoice[0]?.Balance;
            inv.qime__QB_SyncToken__c = json?.QueryResponse?.Invoice[0]?.SyncToken;
        }
        return inv;
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
        invoiceObj.AllowOnlineACHPayment = True;
        invoiceObj.AllowOnlineCreditCardPayment = True;
        if(inv.qime__subtotal__c > 12000){
            invoiceObj.AllowOnlineACHPayment = False;
            invoiceObj.AllowOnlineCreditCardPayment = False;
        }
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
            
            line.Amount = ili.qime__UnitPrice__c * ili.qime__Quantity__c;
            line.Description = ili.Product__r.qime__QB_Description__c;

            //@todo unhardcode this
            line.DetailType = 'SalesItemLineDetail';
            QBInvoiceJSON.SalesItemLineDetail detail = new QBInvoiceJSON.SalesItemLineDetail();

            QBInvoiceJSON.ItemRef itemRef = new QBInvoiceJSON.ItemRef();

            itemRef.value = ili.qime__qb_Id__c; 
            detail.ItemRef = itemRef;
            detail.Qty = ili.qime__Quantity__c;
            detail.UnitPrice = ili.qime__UnitPrice__c;
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
        List<qime__QB_Term__mdt> terms = [SELECT Id, qime__QB_ID__c
                                            FROM qime__QB_Term__mdt 
                                            WHERE label =: term];
        if(terms.size() == 0){
            throw new QBException('Please map the term id for ' + term );
        }
        return terms[0].qime__QB_ID__c;
    }

        /**
     * Map an invoice from QBO JSON to Salesforce
     * @param inv The invoice that is used for the mapping
     * @return The the invoice that can be crud to salesforce
     */
    // public static invoiceReturn mapInvoiceData(Invoice__c inv, QBInvoiceQueryJSON json){
    //     List<Payment__c> payments = new List<Payment__c>();
    //     if(json.QueryResponse.Invoice.size() > 0){
    //         inv.balance_Due__c = json.QueryResponse.Invoice[0].Balance;
    //         for(QBInvoiceQueryJSON.Invoice invoice : json.QueryResponse.Invoice){
    //             for(QBInvoiceQueryJSON.LinkedTxn txn : invoice.LinkedTxn){
    //                 Payment__c p = new Payment__c();
    //                 p.qbo_id__c = txn.TxnId;
    //                 p.qbo_Invoice_id__c = invoice.Id;
    //                 payments.add(p);
    //             }

    //         }
    //     }

    //     invoiceReturn returnVar = new invoiceReturn();
    //     returnVar.payments = payments;
    //     returnVar.inv = inv;
    //     return returnVar;
    // }

    /**
     * Map an payment from QBO JSON to Salesforce
     * @param p The payment that is used for the mapping
     * @return The the payment that can be crud to salesforce
     */
    public static qime__Payment__c mapPaymentData(qime__Payment__c p, QBPaymentQueryJSON json){
        if(json.QueryResponse.Payment.size() > 0){
            p.Amount__c = json.QueryResponse.Payment[0].TotalAmt;
            p.Transaction_Date__c = Date.valueOf(json.QueryResponse.Payment[0].TxnDate);

        }
        return p;
    }

}
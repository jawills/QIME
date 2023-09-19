public class QBInvoiceHelper {
    public static void mapInvoices(String query){
        List<Invoice__c> invList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
        List<Invoice_Payment__c> invpmtList = new List<Invoice_Payment__c>();
        List<Payment__c> pmtList = new List<Payment__c>();

        QBInvoiceQueryJSON queryJson = QBCallout.queryInvoices(query);
        List<SObject> returnList = QBMap.mapInvoices(queryJson);
        for(SObject so : returnList){
            System.debug(so);
            if(so instanceOf Invoice__c){
                invList.add((Invoice__c) so);
            }else if(so instanceof Invoice_Line_Item__c){
                iliList.add((Invoice_Line_Item__c) so);
            }else if(so instanceof Invoice_Payment__c){
                invpmtList.add((Invoice_Payment__c) so);
            }else if(so instanceof Payment__c){
                pmtList.add((Payment__c) so);
            }
        }

        Database.UpsertResult [] invoiceResults = Database.upsert(invList,Invoice__c.QB_Id__c,false);
        for(Database.UpsertResult result : invoiceResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] iliResults = Database.upsert(iliList,Invoice_Line_Item__c.QB_Id__c,false);
        for(Database.UpsertResult result : iliResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] invpmntResults = Database.upsert(invpmtList,Invoice_Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : invpmntResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] pmtResults = Database.upsert(pmtList,Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : pmtResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
    }

    public static void mapInvoice(Invoice__c inv){
        List<Invoice__c> invList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
        List<Invoice_Payment__c> invpmtList = new List<Invoice_Payment__c>();
        List<Payment__c> pmtList = new List<Payment__c>();
        
        if(String.isBlank(inv.QB_Id__c)){
            throw new QBException('Please enter a QB Id');
        }
        String query = 'select * from Invoice where id = \''+ inv.QB_Id__c + '\'';
        QBInvoiceQueryJSON queryJson = QBCallout.getInvoice(inv);
        //Check if an invoice was found
        if(queryJson != null){
            if(queryJson.QueryResponse.Invoice.size() == 1){
                inv.QB_Id__c = queryJson.QueryResponse.Invoice[0].Id;
                inv.QB_SyncToken__c = queryJson.QueryResponse.Invoice[0].SyncToken;
            }else{
                //Multiple Customer Error Handling
                throw new ListException(); 
            }
        }
        List<SObject> returnList = QBMap.mapInvoices(queryJson);
        for(SObject so : returnList){
            System.debug(so);
            if(so instanceOf Invoice__c){
                invList.add((Invoice__c) so);
            }else if(so instanceof Invoice_Line_Item__c){
                iliList.add((Invoice_Line_Item__c) so);
            }else if(so instanceof Invoice_Payment__c){
                invpmtList.add((Invoice_Payment__c) so);
            }else if(so instanceof Payment__c){
                pmtList.add((Payment__c) so);
            }
        }

        Database.UpsertResult [] invoiceResults = Database.upsert(invList,Invoice__c.QB_Id__c,false);
        for(Database.UpsertResult result : invoiceResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] iliResults = Database.upsert(iliList,Invoice_Line_Item__c.QB_Id__c,false);
        for(Database.UpsertResult result : iliResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] invpmntResults = Database.upsert(invpmtList,Invoice_Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : invpmntResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] pmtResults = Database.upsert(pmtList,Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : pmtResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
    }


    public static void createOrUpdateInvoice(Invoice__c inv){
        List<Invoice__c> invList = new List<Invoice__c>();
        List<Invoice_Line_Item__c> iliList = new List<Invoice_Line_Item__c>();
        List<Invoice_Payment__c> invpmtList = new List<Invoice_Payment__c>();
        List<Payment__c> pmtList = new List<Payment__c>();
        String customerId = inv.Opportunity__r.Account.QB_Id__c;
        String invoiceJson = QBMap.mapInvoice(inv, inv.Invoice_Line_Items__r, customerId);
        QBInvoiceResponseJSON resJSON = QBCallout.createInvoice(invoiceJson);

        List<SObject> returnList = QBMap.mapInvoiceData(inv, inv.Invoice_Line_Items__r, resJSON);
        for(SObject so : returnList){
            System.debug(so);
            if(so instanceOf Invoice__c){
                invList.add((Invoice__c) so);
            }else if(so instanceof Invoice_Line_Item__c){
                iliList.add((Invoice_Line_Item__c) so);
            }
        }

        Database.UpsertResult [] invoiceResults = Database.upsert(invList,false);
        for(Database.UpsertResult result : invoiceResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] iliResults = Database.upsert(iliList,false);
        for(Database.UpsertResult result : iliResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }

    }

    public static Invoice__c getInvoice(Id invId){
        return [SELECT Id,
                     Due_Date__c,
                      Subtotal__c,
                      Balance__c,
                       Name, 
                       QB_Id__c,
                       Opportunity__r.Account.QB_Id__c, 
                       QB_SyncToken__c,
                       Terms__c,
                       Tax__c,
                       Email__c,
                       Shipping_Handling__c,
                       Allow_Online_ACH_Payment__c,
                       Allow_Online_CC_Payment__c,
                       Bill_City__c,
                       Bill_Street__c,
                       Bill_Suite__c,
                       Bill_State__c,
                       Bill_Zip__c,
                       Bill_Country__c,
                       Ship_City__c,
                       Ship_Street__c,
                       Ship_Suite__c,
                       Ship_Zip__c,
                       Ship_State__c,
                       Ship_Country__c,
                       (SELECT Id, Unit_Price__c, Quantity__c, 
                                Amount__c, ItemRef_Id__c, QB_Id__c,
                                Product__r.QB_Id__c, Product__r.QB_Description__c,
                                 LineNum__c, 
                                Product__c, Description__c, Taxable__c,
                                Service_Date__c
                       FROM Invoice_Line_Items__r)
                    FROM Invoice__c 
                    WHERE Id =: invId];
    }
}
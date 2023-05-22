public class QBInvoiceHelper {
    public static void mapInvoices(String query){
        List<qime__Invoice__c> invList = new List<qime__Invoice__c>();
        List<qime__Invoice_Line_Item__c> iliList = new List<qime__Invoice_Line_Item__c>();
        List<qime__Invoice_Payment__c> invpmtList = new List<qime__Invoice_Payment__c>();
        List<qime__Payment__c> pmtList = new List<qime__Payment__c>();

        QBInvoiceQueryJSON queryJson = QBCallout.queryInvoices(query);
        List<SObject> returnList = QBMap.mapInvoices(queryJson);
        for(SObject so : returnList){
            System.debug(so);
            if(so instanceOf qime__Invoice__c){
                invList.add((qime__Invoice__c) so);
            }else if(so instanceof qime__Invoice_Line_Item__c){
                iliList.add((qime__Invoice_Line_Item__c) so);
            }else if(so instanceof qime__Invoice_Payment__c){
                invpmtList.add((qime__Invoice_Payment__c) so);
            }else if(so instanceof qime__Payment__c){
                pmtList.add((qime__Payment__c) so);
            }
        }

        Database.UpsertResult [] invoiceResults = Database.upsert(invList,qime__Invoice__c.QB_Id__c,false);
        for(Database.UpsertResult result : invoiceResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] iliResults = Database.upsert(iliList,qime__Invoice_Line_Item__c.QB_Id__c,false);
        for(Database.UpsertResult result : iliResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] invpmntResults = Database.upsert(invpmtList,qime__Invoice_Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : invpmntResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] pmtResults = Database.upsert(pmtList,qime__Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : pmtResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
    }

    public static void mapInvoice(qime__Invoice__c inv){
        List<qime__Invoice__c> invList = new List<qime__Invoice__c>();
        List<qime__Invoice_Line_Item__c> iliList = new List<qime__Invoice_Line_Item__c>();
        List<qime__Invoice_Payment__c> invpmtList = new List<qime__Invoice_Payment__c>();
        List<qime__Payment__c> pmtList = new List<qime__Payment__c>();
        
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
            if(so instanceOf qime__Invoice__c){
                invList.add((qime__Invoice__c) so);
            }else if(so instanceof qime__Invoice_Line_Item__c){
                iliList.add((qime__Invoice_Line_Item__c) so);
            }else if(so instanceof qime__Invoice_Payment__c){
                invpmtList.add((qime__Invoice_Payment__c) so);
            }else if(so instanceof qime__Payment__c){
                pmtList.add((qime__Payment__c) so);
            }
        }

        Database.UpsertResult [] invoiceResults = Database.upsert(invList,qime__Invoice__c.QB_Id__c,false);
        for(Database.UpsertResult result : invoiceResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] iliResults = Database.upsert(iliList,qime__Invoice_Line_Item__c.QB_Id__c,false);
        for(Database.UpsertResult result : iliResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] invpmntResults = Database.upsert(invpmtList,qime__Invoice_Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : invpmntResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
        Database.UpsertResult [] pmtResults = Database.upsert(pmtList,qime__Payment__c.QB_Id__c,false);
        for(Database.UpsertResult result : pmtResults){
            if(!result.success){
                System.debug(result.errors);
            }
        }
    }


    public static void createOrUpdateInvoice(qime__Invoice__c inv){
        List<qime__Invoice__c> invList = new List<qime__Invoice__c>();
        List<qime__Invoice_Line_Item__c> iliList = new List<qime__Invoice_Line_Item__c>();
        List<qime__Invoice_Payment__c> invpmtList = new List<qime__Invoice_Payment__c>();
        List<qime__Payment__c> pmtList = new List<qime__Payment__c>();
        String customerId = inv.qime__Opportunity__r.Account.qime__QB_Id__c;
        String invoiceJson = QBMap.mapInvoice(inv, inv.qime__Invoice_Line_Items__r, customerId);
        QBInvoiceResponseJSON resJSON = QBCallout.createInvoice(invoiceJson);

        List<SObject> returnList = QBMap.mapInvoiceData(inv, inv.qime__Invoice_Line_Items__r, resJSON);
        for(SObject so : returnList){
            System.debug(so);
            if(so instanceOf qime__Invoice__c){
                invList.add((qime__Invoice__c) so);
            }else if(so instanceof qime__Invoice_Line_Item__c){
                iliList.add((qime__Invoice_Line_Item__c) so);
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

    public static qime__Invoice__c getInvoice(Id invId){
        return [SELECT Id,
                     Due_Date__c,
                      Subtotal__c,
                      Balance__c,
                       Name, 
                       QB_Id__c,
                       qime__Opportunity__r.Account.qime__QB_Id__c, 
                       QB_SyncToken__c,
                       Terms__c,
                       qime__Tax__c,
                       qime__Email__c,
                       Shipping_Handling__c,
                       qime__Allow_Online_ACH_Payment__c,
                       qime__Allow_Online_CC_Payment__c,
                       qime__Bill_City__c,
                       qime__Bill_Street__c,
                       qime__Bill_Suite__c,
                       qime__Bill_State__c,
                       qime__Bill_Zip__c,
                       qime__Bill_Country__c,
                       qime__Ship_City__c,
                       qime__Ship_Street__c,
                       qime__Ship_Suite__c,
                       qime__Ship_Zip__c,
                       qime__Ship_State__c,
                       qime__Ship_Country__c,
                       (SELECT Id, qime__Unit_Price__c, qime__Quantity__c, 
                                qime__Amount__c, qime__ItemRef_Id__c, qime__QB_Id__c,
                                qime__Product__r.qime__QB_Id__c, qime__Product__r.qime__QB_Description__c,
                                 qime__LineNum__c, 
                                qime__Product__c, qime__Description__c, qime__Taxable__c,
                                qime__Service_Date__c
                       FROM qime__Invoice_Line_Items__r)
                    FROM qime__Invoice__c 
                    WHERE Id =: invId];
    }
}
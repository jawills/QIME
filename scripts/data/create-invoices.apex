List<Opportunity> opps = [SELECT Id, Name, CloseDate, Amount, AccountId FROM Opportunity];
List<Invoice__c> invs = new List<Invoice__c>();
List<Payment__c> pmnts = new List<Payment__c>();
List<Invoice_Payment__c> invPmts = new List<Invoice_Payment__c>();
Integer invNum = 1000;

for(Opportunity o : opps){
    Invoice__c inv = new Invoice__c();
    inv.name = 'INV-' + String.valueOf(invNum);
    inv.terms__c = 'Net 15';
    inv.total__c = o.amount;
    inv.Opportunity__c = o.Id;
    inv.Balance_Due__c = o.amount;
    inv.Due_Date__c = o.CloseDate.addDays(15);
    inv.Transaction_Date__c = o.CloseDate;
    inv.qb_id__c = 'x' + String.valueOf(invNum);
    inv.account__c = o.AccountId;
    invs.add(inv);
    
    Payment__c pmnt = new Payment__c();
    pmnt.qime__Transaction_Date__c = o.CloseDate;
    pmnt.Name = 'PYMNT-' + String.valueOf(invNum);
    pmnt.qb_id__c = 'x' + String.valueOf(invNum);
    pmnt.Account__c = o.AccountId;
    pmnt.Amount__c = o.Amount;
    pmnts.add(pmnt);
    
    Invoice_Payment__c invPmt = new Invoice_Payment__c();
    invPmt.QB_Id__c = pmnt.qb_id__c;
    invPmt.QB_Invoice_Id__c = inv.qb_id__c + '-' + pmnt.qb_id__c ;
    invPmt.QB_Payment_Id__c = pmnt.qb_id__c;
    invPmt.Invoice__r = new Invoice__c(qb_id__c= inv.qb_id__c);
    invPmt.Payment__r = new Payment__c(qb_id__c= pmnt.qb_id__c);

    invPmts.add(invPmt);
    invNum++;
}

Database.update(invs, Invoice__c.qb_id__c);
Database.update( pmnts, Payment__c.qb_id__c);
Database.update( invPmts, Invoice_Payment__c.qb_id__c);
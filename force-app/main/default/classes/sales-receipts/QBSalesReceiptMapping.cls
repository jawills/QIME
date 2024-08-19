public class QBSalesReceiptMapping {
  public static List<SObject> mapSalesReceiptToOpportunities(
    QBSalesReceiptQueryJSON srQuery
  ) {
    List<SObject> returnList = new List<SObject>();
    if (srQuery?.QueryResponse?.SalesReceipt == null) {
      return new List<SObject>();
    }
    for (
      QBSalesReceiptQueryJSON.SalesReceipt salesreceipt : srQuery
        ?.QueryResponse
        ?.SalesReceipt
    ) {
      Map<String, Id> pbeMap = getPricebookMap();
      Opportunity opp = new Opportunity();
      Decimal subtotal = 0.0;
      opp.QBO_ID__c = salesreceipt.Id;
      opp.QBO_SyncToken__c = salesreceipt.SyncToken;
      opp.Document_Number__c = salesreceipt.DocNumber;
      opp.name = 'SR-' + salesreceipt.DocNumber;
      opp.CloseDate = Date.valueOf(salesreceipt.TxnDate);
      opp.Customer_Id__c = salesreceipt.CustomerRef?.value;
      opp.StageName = QIMEParameter.SALES_RECEIPT_STAGE;
      try {
        opp.Delivery_Time__c = (DateTime) Json.deserialize(
          '"' + salesreceipt?.DeliveryInfo?.DeliveryTime + '"',
          DateTime.class
        );
      } catch (Exception e) {
        System.debug(e);
      }

      opp.all_emails__c = salesreceipt.BillEmail?.Address;
      opp.all_bcc_emails__c = salesreceipt.BillEmailBcc?.Address;
      opp.all_cc_emails__c = salesreceipt.BillEmailCc?.Address;
      opp.payment_Method__c = salesreceipt.PaymentMethodRef?.name;
      opp.class__c = salesreceipt?.ClassRef?.name;

      // Payment Status
      if (
        salesreceipt?.CreditCardPayment?.CreditChargeResponse?.Status ==
        'Completed'
      ) {
        opp.Payment_Status__c = 'paid_payment_success';
      } else if (
        salesreceipt?.CreditCardPayment?.CreditChargeResponse?.Status ==
        'Unknown'
      ) {
        opp.Payment_Status__c = 'paid_payment_failed';
      } else if (
        salesreceipt.CreditCardPayment == null &&
        salesreceipt.Balance == 0
      ) {
        opp.Payment_Status__c = 'paid';
      } else if (salesreceipt.TotalAmt == 0 && salesreceipt.Balance == 0) {
        opp.Payment_Status__c = 'void';
      } else {
        System.debug('Could not log status for SR ' + salesreceipt.DocNumber);
      }
      opp.Balance__c = salesreceipt.Balance;
      if (salesreceipt?.TxnTaxDetail?.TotalTax != null) {
        opp.tax__c = salesreceipt?.TxnTaxDetail?.TotalTax;
      }
      Integer lineCount = 0;

      for (QBSalesReceiptQueryJSON.Line line_item : salesreceipt.Line) {
        OpportunityLineItem oli = new OpportunityLineItem();
        Opportunity oppRef = new Opportunity();
        oppRef.QBO_Id__c = salesreceipt.Id;
        oli.QBO_ID__c = salesreceipt.Id + '-' + line_item.id;
        oli.LineNum__c = line_item.LineNum;
        oli.UnitPrice = line_item.Amount;
        oli.Description = line_item.Description;
        if (line_item?.DetailType == 'SalesItemLineDetail') {
          oli.ItemRef_Id__c = line_item?.SalesItemLineDetail?.ItemRef?.value;
          if (
            pbeMap.containsKey(line_item?.SalesItemLineDetail?.ItemRef?.value)
          ) {
            oli.PricebookEntryId = pbeMap.get(
              line_item?.SalesItemLineDetail?.ItemRef?.value
            );
          }
          oli.class__c = line_item?.SalesItemLineDetail?.ClassRef?.name;

          oli.Quantity = line_item?.SalesItemLineDetail?.Qty;
          oli.UnitPrice = line_item?.SalesItemLineDetail?.UnitPrice;
        } else if (line_item?.DetailType == 'GroupLineDetail') {
          for (
            QBSalesReceiptQueryJSON.Line bundle_line : line_item
              ?.GroupLineDetail.Line
          ) {
            OpportunityLineItem bundle_oli = new OpportunityLineItem();
            bundle_oli.QBO_ID__c = salesreceipt.Id + '-' + bundle_line.id;
            bundle_oli.LineNum__c = bundle_line.LineNum;
            bundle_oli.UnitPrice = bundle_line.Amount;
            bundle_oli.Opportunity = oppRef;
            bundle_oli.ItemRef_Id__c = bundle_line
              ?.SalesItemLineDetail
              ?.ItemRef
              ?.value;
            if (
              pbeMap.containsKey(
                bundle_line?.SalesItemLineDetail?.ItemRef?.value
              )
            ) {
              oli.PricebookEntryId = pbeMap.get(
                bundle_line?.SalesItemLineDetail?.ItemRef?.value
              );
            }
            bundle_oli.Quantity = bundle_line?.SalesItemLineDetail?.Qty;
            bundle_oli.UnitPrice = bundle_line?.SalesItemLineDetail?.UnitPrice;
            bundle_oli.Description = bundle_line.Description;
            oli.Taxable__c =
              bundle_line?.SalesItemLineDetail?.TaxCodeRef?.value == 'TAX';
            lineCount++;
            returnList.add(bundle_oli);
          }
          continue;
        }

        oli.Opportunity = oppRef;
        if (line_item?.SalesItemLineDetail?.TaxCodeRef?.value == 'TAX') {
          oli.Taxable__c = true;
        }
        if (line_item.DetailType != 'SubTotalLineDetail') {
          lineCount++;
        }
        if (
          line_item.DetailType == 'SalesItemLineDetail' &&
          line_item?.SalesItemLineDetail?.ItemRef?.value == 'SHIPPING_ITEM_ID'
        ) {
          opp.Shipping__c = line_item.Amount;
        }
        if (
          line_item.DetailType == 'SalesItemLineDetail' ||
          line_item.DetailType == 'GroupLineDetail'
        ) {
          returnList.add(oli);
        }
      }
      opp.QB_Line_Count__c = lineCount;
      returnList.add(opp);
    }
    return returnList;
  }

  /**
   * @return Key: QB Item Id, Value: Pricebook Entry Id
   */
  private static Map<String, Id> getPricebookMap() {
    // Key: QB Item Id, Value: Pricebook Entry Id
    Map<String, Id> pricebookEntryMap = new Map<String, Id>();
    List<PricebookEntry> pbes = [
      SELECT Id, Product2.QB_Id__c
      FROM PricebookEntry
      WHERE
        Pricebook2Id = :QIMEParameter.SALES_RECEIPT_PRICEBOOK
        AND Product2.QB_Id__c != NULL
    ];
    for (PricebookEntry pbe : pbes) {
      pricebookEntryMap.put(pbe.Product2.qime__QB_Id__c, pbe.Id);
    }
    return pricebookEntryMap;
  }
}

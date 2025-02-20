/**
 * This class is the controller for the Global Action 'Sync with QB'. This will glue the code from the QBCallout class to
 * make the QB integration function properly.
 * @author Justin Wills
 * @created 03/16/2023
 * @version v1.0
 */

public with sharing class QBSalesReceiptController {
  public Id oppId { get; set; }
  public Opportunity opp { get; set; }

  public QBSalesReceiptController(ApexPages.StandardController controller) {
    oppId = controller.getRecord().Id;
    opp = [
      SELECT QBO_Id__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
    if (String.isBlank(opp.QBO_Id__c)) {
      throw new QBException('Please enter a QB Id');
    }
  }

  public Pagereference syncQB() {
    String query =
      'select * from SalesReceipt where id = \'' +
      opp.QBO_Id__c +
      '\'';
    List<SObject> returnList = QBSalesReceiptHelper.getSalesReceipts(query);
    QBSalesReceiptHelper.updateObjects(returnList);
    return new PageReference('/' + oppId);
  }
}
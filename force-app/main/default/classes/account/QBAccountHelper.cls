public class QBAccountHelper {
  public static void getIncomeAccounts() {
    QBAccountQueryResponseJSON res = QBCallout.getIncomeAccounts();
    Map<String, String> pickListValues = new Map<String, String>();
    for (QBAccountQueryResponseJSON.Account acc : res.QueryResponse.Account) {
      pickListValues.put(acc.FullyQualifiedName, acc.Id);
    }
    updateIncomeAccountPicklist(pickListValues);
  }

  private static void updateIncomeAccountPicklist(
    Map<String, String> pickListValues
  ) {
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    MetadataService.CustomField customField = new MetadataService.CustomField();
    customField.fullName = 'Product2.qime__Income_Account__c';
    customField.label = 'Income Account';
    customField.type_x = 'Picklist';

    // Define the Value Set and Value Set Definitions
    MetadataService.ValueSet vs = new MetadataService.ValueSet();
    MetadataService.ValueSetValuesDefinition vd = new MetadataService.ValueSetValuesDefinition();

    // Define the picklist values
    List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();

    for (String key : pickListValues.keySet()) {
      MetadataService.CustomValue cv = new MetadataService.CustomValue();
      cv.label = key;
      cv.fullName = pickListValues.get(key);
      cv.isActive = true;
      cv.default_x = false;
      customValues.add(cv);
    }

    vd.value = customValues;
    vs.valueSetDefinition = vd;

    // Use valueSet instead of Picklist
    customField.valueSet = vs;

    List<MetadataService.SaveResult> results = service.createMetadata(
      new List<MetadataService.Metadata>{ customField }
    );
  }
}

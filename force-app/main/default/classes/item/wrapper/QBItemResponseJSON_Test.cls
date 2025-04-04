//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class QBItemResponseJSON_Test {
  public static String json =
    '{' +
    '  \"Item\": {' +
    '    \"FullyQualifiedName\": \"Garden Supplies\", ' +
    '    \"domain\": \"QBO\", ' +
    '    \"Id\": \"19\", ' +
    '    \"Name\": \"Garden Supplies\", ' +
    '    \"TrackQtyOnHand\": true, ' +
    '    \"UnitPrice\": 0, ' +
    '    \"PurchaseCost\": 0, ' +
    '    \"QtyOnHand\": 10, ' +
    '    \"IncomeAccountRef\": {' +
    '      \"name\": \"Sales of Product Income\", ' +
    '      \"value\": \"79\"' +
    '    }, ' +
    '    \"AssetAccountRef\": {' +
    '      \"name\": \"Inventory Asset\", ' +
    '      \"value\": \"81\"' +
    '    }, ' +
    '    \"Taxable\": false, ' +
    '    \"sparse\": false, ' +
    '    \"Active\": true, ' +
    '    \"SyncToken\": \"0\", ' +
    '    \"InvStartDate\": \"2015-01-01\", ' +
    '    \"Type\": \"Inventory\", ' +
    '    \"ExpenseAccountRef\": {' +
    '      \"name\": \"Cost of Goods Sold\", ' +
    '      \"value\": \"80\"' +
    '    }, ' +
    '    \"MetaData\": {' +
    '      \"CreateTime\": \"2015-12-09T11:12:39-08:00\", ' +
    '      \"LastUpdatedTime\": \"2015-12-09T11:12:41-08:00\"' +
    '    }' +
    '  }' +
    '}';
  static testMethod void testParse() {
    QBItemResponseJSON obj = QBItemResponseJSON.parse(json);
    System.assert(obj != null);
  }
}
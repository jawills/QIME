//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class QBItemJSON_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"TrackQtyOnHand\": true, '+
		'  \"Name\": \"Garden Supplies\", '+
		'  \"QtyOnHand\": 10, '+
		'  \"IncomeAccountRef\": {'+
		'    \"name\": \"Sales of Product Income\", '+
		'    \"value\": \"79\"'+
		'  }, '+
		'  \"AssetAccountRef\": {'+
		'    \"name\": \"Inventory Asset\", '+
		'    \"value\": \"81\"'+
		'  }, '+
		'  \"InvStartDate\": \"2015-01-01\", '+
		'  \"Type\": \"Inventory\", '+
		'  \"ExpenseAccountRef\": {'+
		'    \"name\": \"Cost of Goods Sold\", '+
		'    \"value\": \"80\"'+
		'  }'+
		'}';
		QBItemJSON obj = QBItemJSON.parse(json);
		System.assert(obj != null);
	}
}
/**
 * @File Name          : QBInvoiceResponseJSON_Test.cls
 * @Description        : 
 * @Author             : jawills
 * @Group              : 
 * @Last Modified By   : jawills
 * @Last Modified On   : 2019-10-06, 9:19:10 p.m.
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2019-10-06   jawills     Initial Version
**/
//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class QBInvoiceResponseJSON_Test {
	
    public static String json = '{\"Invoice\":{\"Deposit\":0,\"AllowIPNPayment\":false,\"AllowOnlinePayment\":false,\"AllowOnlineCreditCardPayment\":false,\"AllowOnlineACHPayment\":false,\"domain\":\"QBO\",\"sparse\":false,\"Id\":\"147\",\"SyncToken\":\"0\",\"MetaData\":{\"CreateTime\":\"2019-10-06T21:06:24-07:00\",\"LastUpdatedTime\":\"2019-10-06T21:06:24-07:00\"},\"CustomField\":[{\"DefinitionId\":\"1\",\"Type\":\"StringType\"}],\"DocNumber\":\"1040\",\"TxnDate\":\"2019-10-06\",\"CurrencyRef\":{\"value\":\"USD\",\"name\":\"United States Dollar\"},\"LinkedTxn\":[],\"Line\":[{\"Id\":\"1\",\"LineNum\":1,\"Amount\":1000.00,\"DetailType\":\"SalesItemLineDetail\",\"SalesItemLineDetail\":{\"ItemRef\":{\"value\":\"19\",\"name\":\"Services\"},\"ItemAccountRef\":{\"value\":\"124\",\"name\":\"Services\"},\"TaxCodeRef\":{\"value\":\"NON\"}}},{\"Amount\":1000.00,\"DetailType\":\"SubTotalLineDetail\",\"SubTotalLineDetail\":{}}],\"CustomerRef\":{\"value\":\"65\",\"name\":\"Test Account\"},\"ShipFromAddr\":{\"Id\":\"99\",\"Line1\":\"123 Main St\",\"Line2\":\"San Diego, CA  98765\"},\"DueDate\":\"2019-10-06\",\"TotalAmt\":1000.00,\"ApplyTaxAfterDiscount\":false,\"PrintStatus\":\"NeedToPrint\",\"EmailStatus\":\"NotSet\",\"Balance\":1000.00},\"time\":\"2019-10-06T21:06:24.471-07:00\"}';

	// This test method should give 100% coverage
	static testMethod void testParse() {
		QBInvoiceResponseJSON r = QBInvoiceResponseJSON.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.Line objLine = new QBInvoiceResponseJSON.Line(System.JSON.createParser(json));
		System.assert(objLine != null);
		System.assert(objLine.Id == null);
		System.assert(objLine.LineNum == null);
		System.assert(objLine.Amount == null);
		System.assert(objLine.DetailType == null);
		System.assert(objLine.SalesItemLineDetail == null);
		System.assert(objLine.SubTotalLineDetail == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.CurrencyRef objCurrencyRef = new QBInvoiceResponseJSON.CurrencyRef(System.JSON.createParser(json));
		System.assert(objCurrencyRef != null);
		System.assert(objCurrencyRef.value == null);
		System.assert(objCurrencyRef.name == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.Invoice objInvoice = new QBInvoiceResponseJSON.Invoice(System.JSON.createParser(json));
		System.assert(objInvoice != null);
		System.assert(objInvoice.Deposit == null);
		System.assert(objInvoice.AllowIPNPayment == null);
		System.assert(objInvoice.AllowOnlinePayment == null);
		System.assert(objInvoice.AllowOnlineCreditCardPayment == null);
		System.assert(objInvoice.AllowOnlineACHPayment == null);
		System.assert(objInvoice.domain == null);
		System.assert(objInvoice.sparse == null);
		System.assert(objInvoice.Id == null);
		System.assert(objInvoice.SyncToken == null);
		System.assert(objInvoice.MetaData == null);
		System.assert(objInvoice.CustomField == null);
		System.assert(objInvoice.DocNumber == null);
		System.assert(objInvoice.TxnDate == null);
		System.assert(objInvoice.CurrencyRef == null);
		System.assert(objInvoice.LinkedTxn == null);
		System.assert(objInvoice.Line == null);
		System.assert(objInvoice.CustomerRef == null);
		System.assert(objInvoice.ShipFromAddr == null);
		System.assert(objInvoice.DueDate == null);
		System.assert(objInvoice.TotalAmt == null);
		System.assert(objInvoice.ApplyTaxAfterDiscount == null);
		System.assert(objInvoice.PrintStatus == null);
		System.assert(objInvoice.EmailStatus == null);
		System.assert(objInvoice.Balance == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.TaxCodeRef objTaxCodeRef = new QBInvoiceResponseJSON.TaxCodeRef(System.JSON.createParser(json));
		System.assert(objTaxCodeRef != null);
		System.assert(objTaxCodeRef.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.ShipFromAddr objShipFromAddr = new QBInvoiceResponseJSON.ShipFromAddr(System.JSON.createParser(json));
		System.assert(objShipFromAddr != null);
		System.assert(objShipFromAddr.Id == null);
		System.assert(objShipFromAddr.Line1 == null);
		System.assert(objShipFromAddr.Line2 == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.MetaData objMetaData = new QBInvoiceResponseJSON.MetaData(System.JSON.createParser(json));
		System.assert(objMetaData != null);
		System.assert(objMetaData.CreateTime == null);
		System.assert(objMetaData.LastUpdatedTime == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON objQBInvoiceResponseJSON = new QBInvoiceResponseJSON(System.JSON.createParser(json));
		System.assert(objQBInvoiceResponseJSON != null);
		System.assert(objQBInvoiceResponseJSON.Invoice == null);
		//System.assert(objQBInvoiceResponseJSON.time == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.SalesItemLineDetail objSalesItemLineDetail = new QBInvoiceResponseJSON.SalesItemLineDetail(System.JSON.createParser(json));
		System.assert(objSalesItemLineDetail != null);
		System.assert(objSalesItemLineDetail.ItemRef == null);
		System.assert(objSalesItemLineDetail.ItemAccountRef == null);
		System.assert(objSalesItemLineDetail.TaxCodeRef == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.CustomField objCustomField = new QBInvoiceResponseJSON.CustomField(System.JSON.createParser(json));
		System.assert(objCustomField != null);
		System.assert(objCustomField.DefinitionId == null);
		System.assert(objCustomField.Type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		QBInvoiceResponseJSON.LinkedTxn objLinkedTxn = new QBInvoiceResponseJSON.LinkedTxn(System.JSON.createParser(json));
		System.assert(objLinkedTxn != null);
	}
}
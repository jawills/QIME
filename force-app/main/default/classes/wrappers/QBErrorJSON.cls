@SuppressWarnings('PMD.PropertyNamingConventions, PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public class QBErrorJSON {

	public Fault Fault {get;set;} 
	public String time_x {get;set;} 

	public QBErrorJSON(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'Fault') {
						Fault = new Fault(parser);
					} else if (text == 'time') {
						time_x = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'QBErrorJSON consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Error {
		public String Message {get;set;} 
		public String Detail {get;set;} 
		public String code {get;set;} 
		public String element {get;set;} 

		public Error(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Message') {
							Message = parser.getText();
						} else if (text == 'Detail') {
							Detail = parser.getText();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'element') {
							element = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Error consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Fault {
		public List<Error> Error {get;set;} 
		public String type_Z {get;set;} // in json: type

		public Fault(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Error') {
							Error = arrayOfError(parser);
						} else if (text == 'type') {
							type_Z = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Fault consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static QBErrorJSON parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new QBErrorJSON(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do { 
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    private static List<Error> arrayOfError(System.JSONParser p) {
        List<Error> res = new List<Error>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Error(p));
        }
        return res;
    }





}
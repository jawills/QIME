// Taken from the Nebula Logger Parameter Loader:
// https://github.com/jongpie/NebulaLogger/blob/main/nebula-logger/core/main/configuration/classes/LoggerParameter.cls

/**
 * @group Configuration
 * @description Provides a centralized way to load parameters for SObject handlers & plugins,
 *              and casts the parameters to common data types
 */
@SuppressWarnings(
  'PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public class QIMEParameter {
  private static final Set<String> PARAMETERS_TO_LOAD_DURING_TESTS = new Set<String>{};

  /**
   * @description Indicates what stage sales receipts will be created as.
   *              Controlled by the custom metadata record `QIME_Parameter.Sales_Receipt_Stage`, or `Closed Won` as the default
   */
  public static final String SALES_RECEIPT_STAGE {
    get {
      if (SALES_RECEIPT_STAGE == null) {
        SALES_RECEIPT_STAGE = getString('Sales_Receipt_Stage', 'Closed Won');
      }
      return SALES_RECEIPT_STAGE;
    }
    private set;
  }

  /**
   * @description Indicates what pricebook sales receipts will be created as.
   *              Controlled by the custom metadata record `QIME_Parameter.Sales_Receipt_Pricebook`, or `null` as the default
   */
  public static final String SALES_RECEIPT_PRICEBOOK {
    get {
      if (SALES_RECEIPT_PRICEBOOK == null) {
        SALES_RECEIPT_PRICEBOOK = getString('Sales_Receipt_Pricebook', '');
      }
      return SALES_RECEIPT_PRICEBOOK;
    }
    private set;
  }

  /**
   * @description Indicates what stage sales receipts will be created as.
   *              Controlled by the custom metadata record `QIME_Parameter.Sales_Receipt_Hours_Lookback`, or `24` as the default
   */
  public static final Integer SALES_RECEIPT_HOURS_LOOKBACK {
    get {
      if (SALES_RECEIPT_HOURS_LOOKBACK == null) {
        SALES_RECEIPT_HOURS_LOOKBACK = getInteger(
          'Sales_Receipt_Hours_Lookback',
          24
        );
      }
      return SALES_RECEIPT_HOURS_LOOKBACK;
    }
    private set;
  }

  private static final Map<String, QIME_Parameter__mdt> DEVELOPER_NAME_TO_RECORD {
    get {
      if (DEVELOPER_NAME_TO_RECORD == null) {
        DEVELOPER_NAME_TO_RECORD = loadRecords();
      }
      return DEVELOPER_NAME_TO_RECORD;
    }
    private set;
  }
  /**
   * @description Returns the configured value of the field `Value__c` as a `Boolean`
   * @param  parameterDeveloperName The developer name of the instance of `QIME_Parameter__mdt`
   * @param  defaultValue           A default value to return instead of null
   * @return                        The `Boolean` value configured in the matching instance of `QIME_Parameter__mdt`
   *                                Returns the supplied `defaultValue` when no matching parameter is found, or the parameter value is null
   */
  public static Boolean getBoolean(
    String parameterDeveloperName,
    Boolean defaultValue
  ) {
    Boolean parameterValue = (Boolean) castParameterValue(
      parameterDeveloperName,
      Boolean.class
    );
    return parameterValue != null ? parameterValue : defaultValue;
  }

  /**
   * @description Returns the configured value of the field `Value__c` as a `Integer`
   * @param  parameterDeveloperName The developer name of the instance of `LoggerParameter__mdt`
   * @param  defaultValue           A default value to return instead of null
   * @return                        The `Integer` value configured in the matching instance of `LoggerParameter__mdt`
   *                                Returns the supplied `defaultValue` when no matching parameter is found, or the parameter value is null
   */
  public static Integer getInteger(
    String parameterDeveloperName,
    Integer defaultValue
  ) {
    Integer parameterValue = (Integer) castParameterValue(
      parameterDeveloperName,
      Integer.class
    );
    return parameterValue != null ? parameterValue : defaultValue;
  }

  /**
   * @description This method returns the actual parameter if it exists, or if it's empty returns the default value.
   * @param parameterDeveloperName The parameter to return if it exists.
   * @param defaultValue The default value to return when the parameter doesn't exist.
   * @return A string that's retrieved using the parameter if it's not empty, otherwise the string is defaulted to defaultValue.
   */
  public static String getString(
    String parameterDeveloperName,
    String defaultValue
  ) {
    // Since the Value__c field is already a String, this method skips using the method castParameterValue
    String parameterValue = loadParameterValue(parameterDeveloperName);
    return parameterValue != null ? parameterValue : defaultValue;
  }

  /**
   * @description Returns the configured value of the field `Value__c` as a `Id`
   * @param  parameterDeveloperName The developer name of the instance of `LoggerParameter__mdt`
   * @param  defaultValue           A default value to return instead of null
   * @return                        The `Id` value configured in the matching instance of `LoggerParameter__mdt`
   *                                Returns the supplied `defaultValue` when no matching parameter is found, or the parameter value is null
   */
  public static Id getId(String parameterDeveloperName, Id defaultValue) {
    Id parameterValue = (Id) castParameterValue(
      parameterDeveloperName,
      Id.class
    );
    return parameterValue != null ? parameterValue : defaultValue;
  }

  private static Map<String, QIME_Parameter__mdt> loadRecords() {
    Map<String, QIME_Parameter__mdt> parameters = QIME_Parameter__mdt.getAll()
      .clone();
    if (System.Test.isRunningTest()) {
      // Keep a copy of any records that *should* be loaded during tests
      // Currently, only the record `SystemDebugMessageFormat` has a use case for this functionality,
      // but others can be easily added if other use cases are found
      Map<String, QIME_Parameter__mdt> parametersToLoadDuringTests = new Map<String, QIME_Parameter__mdt>();
      for (String testContextParameterName : PARAMETERS_TO_LOAD_DURING_TESTS) {
        if (parameters.containsKey(testContextParameterName)) {
          parametersToLoadDuringTests.put(
            testContextParameterName,
            parameters.get(testContextParameterName)
          );
        }
      }
      parameters.clear();
      parameters.putAll(parametersToLoadDuringTests);
    }
    return parameters;
  }

  private static Object castParameterValue(
    String parameterDeveloperName,
    System.Type dataType
  ) {
    String parameterValue = loadParameterValue(parameterDeveloperName);
    if (parameterValue == null) {
      return null;
    } else {
      return System.JSON.deserialize(parameterValue, dataType);
    }
  }

  private static String loadParameterValue(String parameterDeveloperName) {
    return DEVELOPER_NAME_TO_RECORD.get(parameterDeveloperName)?.Value__c;
  }
}
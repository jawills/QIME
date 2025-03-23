public with sharing class QIMEUtil {
  public static void printResult(Database.UpsertResult[] results) {
    for (Database.UpsertResult result : results) {
      if (!result.isSuccess()) {
        System.debug(result);
      }
    }
  }

  public static void printResult(Database.UpsertResult result) {
    if (!result.isSuccess()) {
      System.debug(result);
    }
  }

  public static void printResult(Database.SaveResult[] results) {
    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        System.debug(result);
      }
    }
  }
}

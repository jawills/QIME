public with sharing class SchedulerController {
  public static final String INVOICE_JOB_NAME = 'QB - Invoice XX:00';
  public static final String PAYMENT_JOB_NAME = 'QB - Payment XX:05';
  public static final String TERM_JOB_NAME = 'QB - TERM XX:10';
  public static final String CUSTOMER_JOB_NAME = 'QB - Customr XX:30';
  public static final String SALES_RECEIPT_JOB_NAME = 'QB - Sales Receipt XX:15';

  @AuraEnabled
  public static ScheduledJobs getScheduledJobs() {
    ScheduledJobs jobs = new ScheduledJobs();
    jobs.invoiceJob = getInvoiceJob();
    jobs.paymentJob = getPaymentJob();
    jobs.termJob = getTermJob();
    jobs.customerJob = getCustomerJob();
    jobs.salesReceiptJob = getSalesReceiptJob();
    return jobs;
  }

  private static Boolean getInvoiceJob() {
    List<CronTrigger> invJob = [
      SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :INVOICE_JOB_NAME
    ];
    return invJob.size() > 0;
  }

  private static Boolean getPaymentJob() {
    List<CronTrigger> payJob = [
      SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :PAYMENT_JOB_NAME
    ];
    return payJob.size() > 0;
  }

  private static Boolean getTermJob() {
    List<CronTrigger> termJob = [
      SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :TERM_JOB_NAME
    ];
    return termJob.size() > 0;
  }

  private static Boolean getCustomerJob() {
    List<CronTrigger> customerJob = [
      SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :CUSTOMER_JOB_NAME
    ];
    return customerJob.size() > 0;
  }

  private static Boolean getSalesReceiptJob() {
    List<CronTrigger> salesReceiptJob = [
      SELECT Id, CronJobDetail.Name, CronJobDetail.Id, State
      FROM CronTrigger
      WHERE CronJobDetail.Name = :SALES_RECEIPT_JOB_NAME
    ];
    return salesReceiptJob.size() > 0;
  }

  @AuraEnabled
  public static void scheduleInvoiceJob() {
    System.schedule(INVOICE_JOB_NAME, '0 0 * * * ?', new QBInvoiceBatch());
  }

  @AuraEnabled
  public static void schedulePaymentJob() {
    System.schedule(PAYMENT_JOB_NAME, '0 5 * * * ?', new QBPaymentBatch());
  }

  @AuraEnabled
  public static void scheduleTermJob() {
    System.schedule(TERM_JOB_NAME, '0 10 * * * ?', new QBTermBatch());
  }

  @AuraEnabled
  public static void scheduleCustomerJob() {
    System.schedule(CUSTOMER_JOB_NAME, '0 30 * * * ?', new QBCustomerBatch());
  }

  @AuraEnabled
  public static void scheduleSalesReceiptJob() {
    System.schedule(
      SALES_RECEIPT_JOB_NAME,
      '0 15 * * * ?',
      new QBCustomerBatch()
    );
  }

  @AuraEnabled
  public static void unscheduleInvoiceJob() {
    unscheduleJob(INVOICE_JOB_NAME);
  }

  @AuraEnabled
  public static void unschedulePaymentJob() {
    unscheduleJob(PAYMENT_JOB_NAME);
  }

  @AuraEnabled
  public static void unscheduleTermJob() {
    unscheduleJob(TERM_JOB_NAME);
  }

  @AuraEnabled
  public static void unscheduleCustomerJob() {
    unscheduleJob(CUSTOMER_JOB_NAME);
  }

  @AuraEnabled
  public static void unscheduleSalesReceiptJob() {
    unscheduleJob(SALES_RECEIPT_JOB_NAME);
  }

  private static void unscheduleJob(String jobName) {
    List<CronTrigger> jobList = [
      SELECT Id
      FROM CronTrigger
      WHERE CronJobDetail.Name = :jobName
    ];
    for (CronTrigger job : jobList) {
      System.abortJob(job.id);
    }
  }

  @SuppressWarnings('PMD.ApexDoc, PMD.TooManyFields')
  public class ScheduledJobs {
    @AuraEnabled
    public Boolean invoiceJob { get; set; }
    @AuraEnabled
    public Boolean paymentJob { get; set; }
    @AuraEnabled
    public Boolean termJob { get; set; }
    @AuraEnabled
    public Boolean customerJob { get; set; }
    @AuraEnabled
    public Boolean salesReceiptJob { get; set; }
  }
}

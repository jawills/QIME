public class OverviewControllerHelper {

    public static Organization getOrganization(){
        return [
            SELECT
                Id,
                CreatedDate,
                InstanceName,
                IsSandbox,
                Name,
                OrganizationType,
                TrialExpirationDate
            FROM Organization
        ];
    }
}
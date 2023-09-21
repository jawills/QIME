global class QIME {
    @TestVisible
    private static final String CURRENT_VERSION_NUMBER = 'v2.7.0';

    /**
     * @description Returns the current version number of QIME Logger
     * @return The current version number, in the format `v0.0.0`
     */
    global static String getVersionNumber() {
        return CURRENT_VERSION_NUMBER;
    }

    global static String getSessionIdFromVFPage(PageReference visualforcePage){
        String content = visualforcePage.getContent().toString();
        System.debug(content);
        return content;
    }
    
    public class SessionId {
        public String sessionId;
    }
}
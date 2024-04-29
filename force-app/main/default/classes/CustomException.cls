public with sharing class CustomException extends Exception {
    public static final String GENERIC_ERROR = 'An unexpected error occurred';

    /**
     * Handles API response errors. If an error message exists in the
     * response, then this message will be sent to the user-facing error.
     * Otherwise, a generic message is sent.
     * @param res API response
     */
    public CustomException(HttpResponse res) {
        String apiStatusMsg = 'API status ' + res.getStatusCode() + ': ';

        if(String.isBlank(res.getBody()) || !res.getBody().startsWith('{')) {
            this.setMessage(apiStatusMsg + GENERIC_ERROR);
        }

        else {
            try {
                CountryLayerService.ApiError errorRes = (CountryLayerService.ApiError)JSON.deserialize(
                    res.getBody(),
                    CountryLayerService.ApiError.class
                );
                this.setMessage(apiStatusMsg + errorRes.error.info);
            }
            catch(Exception ex) {
                this.setMessage(apiStatusMsg + GENERIC_ERROR);
            }
        }
    }

    /**
     * Joins error messages from DML to be sent in a user-facing error.
     * @param dmlErrors Errors from DML operations
     */
    public CustomException(List<Database.Error> dmlErrors) {
        String message = '';
        for(Database.Error err : dmlErrors) {
            message += err.getMessage() + '. ';
        }
        this.setMessage(message);
    }
}
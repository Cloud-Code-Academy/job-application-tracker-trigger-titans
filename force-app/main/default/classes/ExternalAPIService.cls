public with sharing class ExternalAPIService {
    @AuraEnabled(cacheable=true)
    public static String callOpenAIApi(String body) {
        // Set up the HTTP request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:OpenAI/v1/chat/completions');
        request.setMethod('POST');
        request.setBody(body);

        // Send the request and get the response
        HttpResponse response = http.send(request);

        // Check the response
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('Error calling external API: ' + response.getStatus());
        }
    }
}
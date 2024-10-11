@isTest
public class ExternalAPIServiceTest {
    
    // Mock class for successful HTTP response
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"id": "cmpl-5Ov6wQOx7z", "object": "text_completion", "choices": [{"message": {"content": "This is a mocked response from OpenAI."}}]}');
            return res;
        }
    }
    
    // Mock class for error HTTP response
    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error": "Invalid request"}');
            return res;
        }
    }

    // Positive test case: Validate the successful response from the external API
    @isTest
    static void testCallOpenAIApi_Success() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Define a sample request body
        String requestBody = '{"model": "text-davinci-003", "prompt": "Write a cover letter."}';
        
        // Call the method and assert the response
        String response = ExternalAPIService.callOpenAIApi(requestBody);
        System.assertNotEquals(null, response, 'Response should not be null.');
        System.assert(response.contains('mocked response from OpenAI'), 'The response should contain the mocked response.');
    }

    // Negative test case: Validate the behavior when an error response is received
    @isTest
    static void testCallOpenAIApi_Error() {
        // Set up the mock response for error scenario
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        // Define a sample request body
        String requestBody = '{"model": "gpt-4o-mini", "messages": [{"role": "user", "content": "Write a cover letter."}]}';
        
        // Call the method and expect an exception
        try {
            String response = ExternalAPIService.callOpenAIApi(requestBody);
            System.assert(false, 'Exception should have been thrown for error response.');
        } catch (AuraHandledException ex) {
            // Verify that the exception message is as expected
            System.assertEquals('Error calling external API: 400', ex.getMessage(), 'Error message should match.');
        }
    }
}

@isTest
global class QueueableZXingCallMock implements HttpCalloutMock{

    public String recordId;
    public Integer statusCode;
    public String bodyString;

    public QueueableZXingCallMock(String recordId, Integer statusCode, String bodyString){
        System.debug('###ueueableZXingCallMock');
        this.recordId = recordId;
        this.statusCode = statusCode;
        this.bodyString = bodyString;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        String Body;
        Body = bodyString;
        Body = Body + 'Raw text</td><td><pre>';
        Body = Body + recordId;
        Body = Body + '</pre></td></tr><tr><td>Raw bytes';
        response.setBody(Body);
        System.debug('###response ' + response);
        return response; 
    }

}
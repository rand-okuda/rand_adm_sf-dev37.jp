@isTest
global class QueueableGoogleCallMock implements HttpCalloutMock{

    public QueueableGoogleCallMock(){
        System.debug('###QueueableGoogleCallMock');
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        Blob bodyBlob = Blob.valueof('DummyString');
        response.setBodyAsBlob(bodyBlob);
        System.debug('###response ' + response);
        return response; 
    }

}
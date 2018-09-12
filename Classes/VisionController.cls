public class VisionController {

    public String base64{get;set;}
    List<Vision.Prediction> predictions = new List<Vision.Prediction>();
    public VisionController (){
      base64 = null;
    }

    public PageReference saveBase64(){
      base64 = (Apexpages.currentPage().getParameters().get('base64')).replace('data:image/jpeg;base64,','');
      System.debug('base64='+base64);
      return null;
    }
    // You can upload the `einstein_platform.pem` into your Salesforce org as `File` sObject and read it as below
    public String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = '[EMAIL]';
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        String access_token = JWTBearerFlow.getAccessToken('https://api.einstein.ai/v2/oauth2/token', jwt);
        return access_token;
    }

    public List<Vision.Prediction> getCallVisionUrl() {
        // Get a new token
        String access_token = getAccessToken();

        // Make a prediction using URL to a file
        return Vision.predictUrl('https://einstein.ai/images/generalimage.jpg',access_token,'GeneralImageClassifier');
    }

    public List<Vision.Prediction> getCallVisionContent() {
        // Get a new token
        String access_token = getAccessToken();

        // Make a prediction for an image stored in Salesforce
        // by passing the file as blob which is then converted to base64 string
        ContentVersion content = [SELECT Title,VersionData FROM ContentVersion where Id = '[contentId]' LIMIT 1];
        return Vision.predictBlob(content.VersionData, access_token, 'GeneralImageClassifier');
    }

    public List<Vision.Prediction> getCallVisionContent64() {
        // Get a new token

        System.debug('2.base64='+base64);
        String access_token = getAccessToken();

        // Make a prediction for an image stored in Salesforce
        // by passing the file as blob which is then converted to base64 string
        return Vision.predictBase64(base64, access_token, '[ModelId]');
    }
}

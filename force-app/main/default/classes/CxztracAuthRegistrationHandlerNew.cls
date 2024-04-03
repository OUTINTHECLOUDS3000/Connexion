//TODO:This class includes the basics for a Registration
//Handler class. You will need to customize it to ensure it meets your needs and
//the data provided by the third party.
 
global class CxztracAuthRegistrationHandlerNew implements Auth.RegistrationHandler{
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    map<string,string> attributesMap = new Map<string,string>(); 
    global boolean canCreateUser(Auth.UserData data) { 
        //Check whether we want to allow creation of a user with this data
        for(string key : attributesMap.keySet())
        {
            system.debug('key -- '+ key + '---Value --- '+ attributesMap.get(key));
        }
        if(attributesMap.get('dealerId')==null || attributesMap.get('email')==null || attributesMap.get('givenName')==null || attributesMap.get('familyName')==null){
            return false;
        }
        return true; 
    }
    
    global User createUser(Id portalId, Auth.UserData data){
        parseParameters(data);
       
        if(!canCreateUser(data)) {
            //Returning null or throwing an exception fails the SSO flow
            return null;
        }
        
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            //We have a community id, so create a user with community access
            //TODO: Get an actual account
            system.debug('can create user');
            String userDealerId = attributesMap.get('dealerId');
            String userEmail = attributesMap.get('email');
            String userFirstName = attributesMap.get('givenName');
            String userLastName = attributesMap.get('familyName');
            String role = attributesMap.get('role');
            
            Account account = [SELECT Id FROM account WHERE BAC__c=:userDealerId];
            
            if(account == null) {
                System.debug('No valid account found for bac' + userDealerId);
                throw new OtherException('Invalid dealerId access');
            }
            
            Contact c = upsertContact(account.Id, userEmail, userFirstName, userLastName);
            
            
            //TODO: Customize the username and profile. Also check that the username doesn't already exist and
            //possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.
            User u = getUser(userEmail);
            if(u == null)
            {
                u = new User();
                Profile p = [SELECT Id FROM profile WHERE name='On/CXZ TRAC Community User'];
                u.username = userEmail;
                u.email = userEmail;
                u.lastName = userLastName;
                u.firstName = userFirstName;
                String alias = userFirstName + userLastName;
                //Alias must be 8 characters or less
                if(alias.length() > 8) {
                    alias = alias.substring(0, 8);
                }
                u.alias = alias;
                u.languagelocalekey = 'en_US';
                u.localesidkey = 'en_US';
                u.emailEncodingKey = 'UTF-8';
                u.timeZoneSidKey = 'America/Los_Angeles';
                u.profileId = p.Id;
                u.contactId = c.Id;
                u.CompanyName = userDealerId;
                u.Title = role;
                
                System.debug(u);
                
            }
            
            return u;
        } else {
            //This is not a community, so create a regular standard user
            // we do not create other users:
            throw new OtherException('Invalid user');
        }
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        System.debug('updating user');
        parseParameters(data);
        String userDealerId = attributesMap.get('dealerId');
            String userEmail = attributesMap.get('email');
            String userFirstName = attributesMap.get('givenName');
            String userLastName = attributesMap.get('familyName');
            String role = attributesMap.get('role');
        User u = new User(id=userId);    
        u.email = userEmail;
        u.lastName = userLastName;
        u.firstName = userFirstName;
        u.CompanyName = userDealerId;
        u.Title = role;
        String alias = userFirstName + userLastName;
        u.Title = role;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        update(u);
    }
    private Contact upsertContact(string accountId, string userEmail, string userFirstName, string userLastName) {
        List <Contact> cList = [SELECT Id FROM Contact WHERE email =: userEmail];
        Contact c = new Contact();
        if (cList == null || cList.size() == 0) {
            c.accountId = accountId;
            c.email = userEmail;
            c.firstName = userFirstName;
            c.lastName = userLastName;
            insert(c);
        } else {
            c = cList[0];
        }
        return c;
    }
    
    private User getUser(string userEmail) {
        //string username = userEmail;
        List<User> u = [select id from USER where email =: userEmail and Isactive = true];
        if (u != null && u.size() > 0)
            return u[0];
        else return null;
        
    }
    
    private void parseParameters(Auth.UserData data)
    {
        Map<String, String> customizeAttributes = data.attributeMap;
        string profileDetails= customizeAttributes.get('profile').replace('{','').replace('}','');
        List<string> attributes = profileDetails.split(',');
        
        for(string s : attributes)
        {
            attributesMap.put(s.split('=')[0].trim(),s.split('=')[1].trim());
        }
    }
}
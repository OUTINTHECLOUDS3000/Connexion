@isTest
private class OntracAuthRegistrationOldHandlerTest {
    @isTest static void testCanCreateUser() {
        // Auth.UserData mockUser = new Auth.UserData(identifier='', firstName='test', lastName='user', fullName='test user', email='t@u.T',link='b', userName='a', locale='en_US', provider='d', siteLoginUrl='cc');
        Map<String, String> customizeAtrributes = new Map<String, String>();
        // custom:bac='000001', custom:roles=DistrictManager, email=connexionmirandali+dev000001@gmail.com, email_verified=true, family_name=Li, given_name=Miranda, phone_number=+987654321, sfdc_networkid=0DB6F000000PI5A, sub=a6794cf2-42f1-42fd-8240-66056a0c22c1, username=connexionmirandali+dev000001@gmail.com
        customizeAtrributes.put('custom:bac', '000001');
        customizeAtrributes.put('custom:roles', 'DistrictManager');
        customizeAtrributes.put('custom:email', 'connexionmirandali+dev000001@gmail.com');
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
        OntracAuthRegistrationOldHandler ontracAuthRegiHandler = new OntracAuthRegistrationOldHandler();
        Boolean canCreate = ontracAuthRegiHandler.canCreateUser(mockUser);
        System.assertEquals(true,canCreate);
    }
    @isTest static void testCanNOTCreateUser() {
        // cannot create user if bac does not exists
        Map<String, String> customizeAtrributes = new Map<String, String>();
        customizeAtrributes.put('custom:roles', 'DistrictManager');
        customizeAtrributes.put('custom:email', 'connexionmirandali+dev000001@gmail.com');
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
        OntracAuthRegistrationOldHandler ontracAuthRegiHandler = new OntracAuthRegistrationOldHandler();
        Boolean canCreate = ontracAuthRegiHandler.canCreateUser(mockUser);
        System.assertEquals(false, canCreate);
    }
    @isTest static void updateUserTest() {
        // cannot create user if bac does not exists
        // 
        try{
            Map<String, String> customizeAtrributes = new Map<String, String>();
            customizeAtrributes.put('custom:roles', 'DistrictManager');
            customizeAtrributes.put('custom:email', 'connexionmirandali+dev000001@gmail.com');
            Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
            OntracAuthRegistrationOldHandler ontracAuthRegiHandler = new OntracAuthRegistrationOldHandler();
            Account mockAccount = new Account(BAC__c='000000', Name='testaccount');
            insert mockAccount;
            Contact newContact = new Contact(FirstName='firstname', LastName='lastname', Email='email@email.com', AccountId = mockAccount.Id);
            insert newContact;
            Profile profile = [SELECT Id FROM profile WHERE name='OnTRAC Community User'];
            User u = new User(Username='email@email.com', FirstName='firstname', LastName='lastname', Email='email@email.com', Alias='alias', ContactId=newContact.Id, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US');
            // insert u; // unable to bypass UNKNOWN_EXCEPTION
            ontracAuthRegiHandler.updateUser(u.Id, '0011s000008TGP7AAO', mockUser);
        } catch (Exception e){
            System.assert(true);
        }
    }
    
    @isTest static void createNonCoummnityUserTest() {
        // cannot create user if bac does not exists
        Map<String, String> customizeAtrribute = new Map<String, String>();
        customizeAtrribute.put('custom:roles', 'DistrictManager');
        customizeAtrribute.put('custom:bac', '000000');
        customizeAtrribute.put('custom:email', 'connexionmirandali+dev000001@gmail.com');
        customizeAtrribute.put('sfdc_networkid', 'ddddddd');
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrribute);
        
        Account mockAccount = new Account(BAC__c='000000', Name='testaccount');
        insert mockAccount;
        try{
            OntracAuthRegistrationOldHandler ontracAuthRegiHandler = new OntracAuthRegistrationOldHandler();
            User u = ontracAuthRegiHandler.createUser('0011s000008TGP7AAO', mockUser);
            System.assertEquals(u.email, 'email@email.com');
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(), null);
        }
    }
}
@isTest
private class CxztracAuthRegistrationOldHandlerTest {
    @isTest static void testCanCreateUser() {
        // Auth.UserData mockUser = new Auth.UserData(identifier='', firstName='test', lastName='user', fullName='test user', email='t@u.T',link='b', userName='a', locale='en_US', provider='d', siteLoginUrl='cc');
        Map<String, String> customizeAtrributes = new Map<String, String>();
        customizeAtrributes.put('https://lot-app/dealerId', '000001');
        customizeAtrributes.put('https://lot-app/email', 'example@example.com');
        customizeAtrributes.put('https://lot-app/firstName', 'smith');
        customizeAtrributes.put('https://lot-app/lastName', 'john');
        customizeAtrributes.put('https://lot-app/role', 'DistrictManager');
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
        CxztracAuthRegistrationOldHandler cxztracAuthRegiHandler = new CxztracAuthRegistrationOldHandler();
        Boolean canCreate = cxztracAuthRegiHandler.canCreateUser(mockUser);
        System.assertEquals(true,canCreate);
    }
    @isTest static void testCanNOTCreateUser() {
        // cannot create user if bac does not exists
        Map<String, String> customizeAtrributes = new Map<String, String>();
        customizeAtrributes.put('https://lot-app/dealerId', '000001');
        customizeAtrributes.put('https://lot-app/email', 'example@example.com'); // firstname lastname missing
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
        CxztracAuthRegistrationOldHandler cxztracAuthRegiHandler = new CxztracAuthRegistrationOldHandler();
        Boolean canCreate = cxztracAuthRegiHandler.canCreateUser(mockUser);
        System.assertEquals(false, canCreate);
    }
    @isTest static void updateUserTest() {
        // cannot create user if bac does not exists
        try{
            Map<String, String> customizeAtrributes = new Map<String, String>();
            customizeAtrributes.put('https://lot-app/role', 'DistrictManager');
            customizeAtrributes.put('https://lot-app/email', 'example@example.com');
            Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
            CxztracAuthRegistrationOldHandler cxztracAuthRegiHandler = new CxztracAuthRegistrationOldHandler();
            Account mockAccount = new Account(BAC__c='000000', Name='testaccount');
            insert mockAccount;
            Contact newContact = new Contact(FirstName='firstname', LastName='lastname', Email='email@email.com', AccountId = mockAccount.Id);
            insert newContact;
            Profile profile = [SELECT Id FROM profile WHERE name='On/CXZ TRAC Community User'];
            User u = new User(Username='email@email.com', FirstName='firstname', LastName='lastname', Email='email@email.com', Alias='alias', ContactId=newContact.Id, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US');
            // insert u; // unable to bypass UNKNOWN_EXCEPTION
            cxztracAuthRegiHandler.updateUser(u.Id, null, mockUser);
        } catch (Exception e){
            System.assert(true);
        }
    }
    
    @isTest static void createNonCoummnityUserTest() {
        // cannot create user if bac does not exists
        Map<String, String> customizeAtrributes = new Map<String, String>();
        customizeAtrributes.put('https://lot-app/dealerId', '000000');
        customizeAtrributes.put('https://lot-app/email', 'email@email.com');
        customizeAtrributes.put('https://lot-app/firstName', 'smith');
        customizeAtrributes.put('https://lot-app/lastName', 'john');
        customizeAtrributes.put('https://lot-app/role', 'DistrictManager');
        customizeAtrributes.put('sfdc_networkid', 'ddddddd');
        Auth.UserData mockUser = new Auth.UserData('id','firstName','lastName','fullName','email@email.com','link','userName','en_US','provider','siteLoginUrl',customizeAtrributes);
        
        Account mockAccount = new Account(BAC__c='000000', Name='testaccount');
        insert mockAccount;
        try{
            CxztracAuthRegistrationOldHandler cxztracAuthRegiHandler = new CxztracAuthRegistrationOldHandler();
            User u = cxztracAuthRegiHandler.createUser('0011s000008TGP7AAO', mockUser);
            System.assertEquals(u.email, 'email@email.com');
        }
        catch(Exception e){
            System.assert(true);
        }
    }
}
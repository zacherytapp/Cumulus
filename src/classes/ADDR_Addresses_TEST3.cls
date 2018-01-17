/**
 * Created by smithmichael on 1/17/18.
 */

@isTest
private class ADDR_Addresses_TEST3 {

    /*********************************************************************************************************
    @description
        insert enough addresses to require multiple trigger calls, to ensure our static counters are handled
        appropriately.
    verify:
        address propagated to all contacts and accounts
    **********************************************************************************************************/
    static testMethod void insertManyAddresses() {
        UTIL_Debug.disableDebugLogging();     // Override debug logging for this test because it's an expensive operation
        ADDR_Addresses_TEST.createHHTestData(210, 1);

        // verify that the HH and Contacts share the same address
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id, Name, BillingStreet, BillingCity, BillingState,
                BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude FROM Account]);
        List<Contact> listCon = [SELECT Id, Name, AccountId, is_Address_Override__c, Current_Address__c,
                MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude,
                MailingLongitude FROM Contact];
        system.assertEquals(210, listCon.size());

        for (Contact con : listCon) {
            Account acc = mapAccIdAcc.get(con.AccountId);
            system.assertEquals(true, ADDR_Addresses_TEST.isMatchAddressAccCon(acc, con));
            system.assertEquals(false, con.is_Address_Override__c);
            system.assertNotEquals(null, con.Current_Address__c);
        }
    }

}
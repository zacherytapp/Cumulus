/*
    Copyright (c) 2017, Salesforce.org
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2017
* @group TEMPORARY SOLUTION
* @description Built by Michael Smith as a temporary solution to track field changes to the Account object
*/
@isTest
private class NPSP_TEMP_FieldHistory_TEST {

    static testMethod void test_historyTrigger() {
        Contact c = new Contact(LastName = 'UNITTEST1', FirstName = 'UNITTEST2');

        Test.startTest();

        insert c;
        c = [SELECT Id, AccountId, Account.Name FROM Contact LIMIT 1];
        Account a = c.Account;

        Integer baseChanges = [SELECT Count() FROM NPSP_Field_History__c];
        System.assertEquals(2, [SELECT Count() FROM NPSP_Field_History__c WHERE New_Value__c = 'Record Created']);

        a.Type = 'TypeValue';
        a.Industry = 'Pennington';
        a.AnnualRevenue = 1000;
        a.Description = 'TEST';
        a.npo02__LastCloseDate__c = Date.Today();
        update a;
        System.assertEquals(baseChanges+5, [SELECT Count() FROM NPSP_Field_History__c],
                JSON.serializePretty([SELECT Object_Name__c, Field_API_Name__c, Old_Value__c, New_Value__c
                FROM NPSP_Field_History__c ORDER BY CreatedDate DESC]));

        delete a;
        System.assertEquals(baseChanges+6, [SELECT Count() FROM NPSP_Field_History__c]);

        undelete a;
        System.assertEquals(baseChanges+7, [SELECT Count() FROM NPSP_Field_History__c]);
    }
}
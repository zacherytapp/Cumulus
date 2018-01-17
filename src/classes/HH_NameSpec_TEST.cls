/*
    Copyright (c) 2014 Salesforce.org
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
* @date 2013
* @group Households
* @description tests specific to the HH_NameSpec custom household naming class 
*/

@isTest(IsParallel=true)
private with sharing class HH_NameSpec_TEST {

    /*********************************************************************************************************
    * @description if you only want to run one test in this class, fill in its name here.
    * if you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
        
    /*********************************************************************************************************
    @description
    operation:
        1 contact in household 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void OneContact() {
        if (strTestOnly != '*' && strTestOnly != 'OneContact') return;
        
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John1',
                LastName = 'Doe1'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        //Using the API class just to give it test coverage.
        Household_Naming_Settings__c hns = UTIL_CustomSettings_API.getHouseholdNamingSettings();
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe1 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}}';
        system.assertEquals('HH - Doe1, John1', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John1 Doe1', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John1 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Skipper John1 Doe1 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} {!FirstName} {!LastName} Family';
        system.assertEquals('The John1 Doe1 John1 Doe1 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        2 contact, same lastname in household 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void TwoContactSameLastname() {
        if (strTestOnly != '*' && strTestOnly != 'TwoContactSameLastname') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John2',
                LastName = 'Doe2'
            ),
            new Contact (
                FirstName = 'Jane2',
                LastName = 'Doe2'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe2 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}}';
        system.assertEquals('HH - Doe2, John2 & Jane2', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John2 & Jane2 Doe2', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John2 Dude & Jane2 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Skipper John2 Doe2 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!({!FirstName} {!LastName})} excellent {!FirstName} {!LastName} Family';
        system.assertEquals('The (John2 Doe2) & (Jane2 Doe2) excellent John2 Doe2 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} excellent {!FirstName} {!LastName} Family';
        system.assertEquals('The John2 Doe2 & Jane2 Doe2 excellent John2 Doe2 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        2 contacts, different lastnames in household 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void TwoContactDifferentLastname() {
        if (strTestOnly != '*' && strTestOnly != 'TwoContactDifferentLastname') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John3',
                LastName = 'Doe3'
            ),
            new Contact (
                FirstName = 'Jane3',
                LastName = 'Smith3'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe3 & Smith3 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        system.assertEquals('HH - Doe3, John3 & Smith3, Jane3 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName}}) Family';
        system.assertEquals('The Doe3 (John3) & Smith3 (Jane3) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John3 Doe3 & Jane3 Smith3', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John3 Dude & Jane3 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        3 contacts, 2 different lastnames in household 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void ThreeContactsTwoLastnames() {
        if (strTestOnly != '*' && strTestOnly != 'ThreeContactsTwoLastnames') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John4',
                LastName = 'Doe4'
            ),
            new Contact (
                FirstName = 'Jane4',
                LastName = 'Doe4'
            ),
            new Contact (
                FirstName = 'Sally4',
                LastName = 'Smith4'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe4 & Smith4 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        system.assertEquals('HH - Doe4, John4 & Jane4 & Smith4, Sally4 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName}}) Family';
        system.assertEquals('The Doe4 (John4 & Jane4) & Smith4 (Sally4) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John4 & Jane4 Doe4 & Sally4 Smith4', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John4 Dude, Jane4 Dude & Sally4 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Skipper John4 Doe4 & Sally4 Smith4 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} {!FirstName} {!LastName} Family';
        system.assertEquals('The John4 Doe4 & Jane4 Doe4 John4 Doe4 & Sally4 Smith4 Sally4 Smith4 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        3 contacts, 2 different lastnames in household, contacts' last name is not in the sequence 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void ThreeContactsTwoLastNamesNotInSequenceWhenTheNameFormatHasLastName() {
        if (strTestOnly != '*' && strTestOnly != 'ThreeContactsTwoLastNamesNotInSequenceWhenTheNameFormatHasLastName') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Mr',
                FirstName = 'John5',
                LastName = 'Doe5',
                npe01__WorkEmail__c = 'john5@doe.com'
            ),
            new Contact (
                Salutation = 'Mrs',
                FirstName = 'Sally5',
                LastName = 'Smith5',
                npe01__WorkEmail__c = 'sally5@smith.com'
            ),
            new Contact (
                Salutation = 'Ms',
                FirstName = 'Jane5',
                LastName = 'Doe5',
                npe01__WorkEmail__c = 'jane5@doe.com'
            )
        };
             
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = 'The {!LastName} Family';
        system.assertEquals('The Doe5 & Smith5 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName}: {!{!npe01__WorkEmail__c}} Family';
        system.assertEquals('The Doe5: john5@doe.com, Smith5: sally5@smith.com & Doe5: jane5@doe.com Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName}, {!{!FirstName} {!npe01__WorkEmail__c}} Family';
        system.assertEquals('The Doe5, John5 john5@doe.com, Smith5, Sally5 sally5@smith.com & Doe5, Jane5 jane5@doe.com Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
    
        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName}}) Family';
        system.assertEquals('The Doe5 (John5), Smith5 (Sally5) & Doe5 (Jane5) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LASTNAME} ({!{!firstName}}) Family';
        system.assertEquals('The Doe5 (John5), Smith5 (Sally5) & Doe5 (Jane5) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Mr John5 Doe5, Mrs Sally5 Smith5 & Ms Jane5 Doe5', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Mr John5 Doe5, Mrs Sally5 Smith5 & Ms Jane5 Doe5 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} {!FirstName} {!LastName} Family';
        system.assertEquals('The John5 Doe5 John5 Doe5, Sally5 Smith5 Sally5 Smith5 & Jane5 Doe5 Jane5 Doe5 Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        3 contacts, 2 different lastnames in household, the contacts' last name is not in the sequence 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void ThreeContactsTwoLastNamesNotInSequenceWhenTheNameFormatHasNoLastName() {
        if (strTestOnly != '*' && strTestOnly != 'ThreeContactsTwoLastNamesNotInSequenceWhenTheNameFormatHasNoLastName') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Mr',
                FirstName = 'John6',
                LastName = 'Doe6',
                npe01__WorkEmail__c = 'john6@doe.com'
            ),
            new Contact (
                Salutation = 'Mrs',
                FirstName = 'Sally6',
                LastName = 'Smith6',
                npe01__WorkEmail__c = 'sally6@smith.com'
            ),
            new Contact (
                Salutation = 'Ms',
                FirstName = 'Jane6',
                LastName = 'Doe6',
                npe01__WorkEmail__c = 'jane6@doe.com'
            )
        };
             
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = 'The Family';
        system.assertEquals('The Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!npe01__WorkEmail__c} Family';
        system.assertEquals('The john6@doe.com Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!*{!npe01__WorkEmail__c}*} Family';
        system.assertEquals('The *john6@doe.com*, *sally6@smith.com* & *jane6@doe.com* Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!{!FirstName} {!npe01__WorkEmail__c}} Family';
        system.assertEquals('The John6 john6@doe.com, Sally6 sally6@smith.com & Jane6 jane6@doe.com Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!{!FIRSTname} {!npe01__WORKEMAIL__C}} Family';
        system.assertEquals('The John6 john6@doe.com, Sally6 sally6@smith.com & Jane6 jane6@doe.com Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
    
        hns.Formal_Greeting_Format__c = 'The {!*{!Salutation} {!FirstName}*} Family';
        system.assertEquals('The *Mr John6*, *Mrs Sally6* & *Ms Jane6* Family', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John6 Dude, Sally6 Dude & Jane6 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }
     
    /*********************************************************************************************************
    @description
    operation:
        3 contacts, 2 different lastnames in household, custom fields in format specs 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void ThreeContactsTwoLastnamesCustomFields() {
        if (strTestOnly != '*' && strTestOnly != 'ThreeContactsTwoLastnamesCustomFields') return;                
        
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John7',
                LastName = 'Doe7',
                npe01__WorkEmail__c = 'john7@doe.com'
            ),
            new Contact (
                Salutation = 'Mrs.',
                FirstName = 'Jane7',
                LastName = 'Doe7',
                npe01__WorkEmail__c = 'jane7@doe.com'
            ),
            new Contact (
                FirstName = 'Sally7',
                LastName = 'Smith7'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe7 & Smith7 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName} {!npe01__WorkEmail__c}} Family';
        system.assertEquals('HH - Doe7, John7 john7@doe.com & Jane7 jane7@doe.com & Smith7, Sally7 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName} {!npe01__WorkEmail__c}}) Family';
        system.assertEquals('The Doe7 (John7 john7@doe.com & Jane7 jane7@doe.com) & Smith7 (Sally7) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName} {!npe01__WorkEmail__c}} {!LastName}';
        system.assertEquals('Skipper John7 john7@doe.com & Mrs. Jane7 jane7@doe.com Doe7 & Sally7 Smith7', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} {!npe01__WorkEmail__c} Dude}';
        system.assertEquals('John7 john7@doe.com Dude, Jane7 jane7@doe.com Dude & Sally7 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!npe01__WorkEmail__c} Family';
        system.assertEquals('The Skipper & Mrs. John7 john7@doe.com Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!npe01__WorkEmail__c}} {!FirstName} {!npe01__WorkEmail__c} Family';
        system.assertEquals('The John7 john7@doe.com, Jane7 jane7@doe.com & Sally7 John7 john7@doe.com Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        Test Household Name, and Formal/Informal greetings when Contact field names are case insensitive
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void testHHNamingWhenContactFieldNamesAreCaseInsensitive() {
        if (strTestOnly != '*' && strTestOnly != 'testHHNamingWhenContactFieldNamesAreCaseInsensitive') return;
                
        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John8',
                LastName = 'Doe8'
            ),
            new Contact (
                FirstName = 'Jane8',
                LastName = 'Smith8'
            )
        };
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!lastname} Family';
        system.assertEquals('Doe8 & Smith8 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LASTname}, {!{!FIRSTname}} Family';
        system.assertEquals('HH - Doe8, John8 & Smith8, Jane8 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LASTNAME} ({!{!FIRSTNAME}}) Family';
        system.assertEquals('The Doe8 (John8) & Smith8 (Jane8) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!salutation} {!firstNAME}} {!lAsTnAmE}';
        system.assertEquals('Skipper John8 Doe8 & Jane8 Smith8', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!lastNAME} Dude}';
        system.assertEquals('Doe8 Dude & Smith8 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!firstname} Dude}';
        system.assertEquals('John8 Dude & Jane8 Dude', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
    }

    /*********************************************************************************************************
    @description
    operation:
        6 contacts, 1 lastnames in household 
        Contact overrun set 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void SixContactsOneLastnamesContactOverrun() {
        if (strTestOnly != '*' && strTestOnly != 'SixContactsOneLastnamesContactOverrun') return;
                
        list<Contact> listCon = new list<Contact>();
        Contact c1 = new Contact (
            Salutation = 'Skipper',
            FirstName = 'John9',
            LastName = 'Doe9'
        );
        listCon.add(c1);
        Contact c2 = new Contact (
            FirstName = 'Jane9',
            LastName = 'Doe9'
        );
        listCon.add(c2);
        Contact c3 = new Contact (
            FirstName = 'Sally9',
            LastName = 'Doe9'
        );
        listCon.add(c3);
        Contact c4 = new Contact (
            FirstName = 'Clay9',
            LastName = 'Doe9'
        );
        listCon.add(c4);
        Contact c5 = new Contact (
            FirstName = 'Cloe9',
            LastName = 'Doe9'
        );
        listCon.add(c5);
        Contact c6 = new Contact (
            FirstName = 'Charlie9',
            LastName = 'Doe9'
        );
        listCon.add(c6);
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        hns.Contact_Overrun_Count__c = 5;
        hns.Name_Overrun__c = 'Friends';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe9 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        system.assertEquals('HH - Doe9, John9, Jane9, Sally9, Clay9 & Cloe9 & Friends Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName}}) Family';
        system.assertEquals('The Doe9 (John9, Jane9, Sally9, Clay9 & Cloe9) & Friends Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John9, Jane9, Sally9, Clay9 & Cloe9 Doe9 & Friends', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John9 Dude, Jane9 Dude, Sally9 Dude, Clay9 Dude, Cloe9 Dude & Friends', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Skipper John9 Doe9 & Friends Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} {!FirstName} {!LastName} Family';
        system.assertEquals('The John9 Doe9, Jane9 Doe9, Sally9 Doe9, Clay9 Doe9 & Cloe9 Doe9 John9 Doe9 & Friends Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        // also test common 2 person, 2 overrun count scenario
        hns.Contact_Overrun_Count__c = 2;
        list<Contact> listCon2 = new list<Contact>{c1, c2};
        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John9 & Jane9 Doe9', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon2));
    }

    /*********************************************************************************************************
    @description
    operation:
        6 contacts, 2 lastnames in household 
        Contact overrun set 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void SixContactsTwoLastnamesContactOverrun() {
        if (strTestOnly != '*' && strTestOnly != 'SixContactsTwoLastnamesContactOverrun') return;
                
        list<Contact> listCon = new list<Contact>();
        Contact c1 = new Contact (
            Salutation = 'Skipper',
            FirstName = 'John0',
            LastName = 'Doe0'
        );
        listCon.add(c1);
        Contact c2 = new Contact (
            FirstName = 'Jane0',
            LastName = 'Doe0'
        );
        listCon.add(c2);
        Contact c3 = new Contact (
            FirstName = 'Sally0',
            LastName = 'Doe0'
        );
        listCon.add(c3);
        Contact c4 = new Contact (
            FirstName = 'Clay0',
            LastName = 'Carlson0'
        );
        listCon.add(c4);
        Contact c5 = new Contact (
            FirstName = 'Cloe0',
            LastName = 'Carlson0'
        );
        listCon.add(c5);
        Contact c6 = new Contact (
            FirstName = 'Charlie0',
            LastName = 'Carlson0'
        );
        listCon.add(c6);
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        hns.Contact_Overrun_Count__c = 5;
        hns.Name_Overrun__c = 'Friends';
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals('Doe0 & Carlson0 Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = '{!LastName} - {!{!FirstName}} Family';
        system.assertEquals('Doe0 - John0, Jane0 & Sally0, Carlson0 - Clay0 & Cloe0 & Friends Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'The {!LastName} ({!{!FirstName}}) Family';
        system.assertEquals('The Doe0 (John0, Jane0 & Sally0), Carlson0 (Clay0 & Cloe0) & Friends Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals('Skipper John0, Jane0 & Sally0 Doe0, Clay0 & Cloe0 Carlson0 & Friends', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals('John0 Dude, Jane0 Dude, Sally0 Dude, Clay0 Dude, Cloe0 Dude & Friends', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = 'The {!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('The Skipper John0 Doe0, Clay0 Carlson0 & Friends Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));
        
        hns.Informal_Greeting_Format__c = 'The {!{!FirstName} {!LastName}} {!FirstName} {!LastName} Family';
        system.assertEquals('The John0 Doe0, Jane0 Doe0 & Sally0 Doe0 John0 Doe0, Clay0 Carlson0 & Cloe0 Carlson0 Clay0 Carlson0 & Friends Family', ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

        // ok, let's just test all permutations with overrun!
        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName} Family';
        hns.Contact_Overrun_Count__c = 1;
        system.assertEquals('Skipper John0 Doe0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1}));
        
        hns.Contact_Overrun_Count__c = 2;
        system.assertEquals('Skipper John0 & Jane0 Doe0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c2}));
        
        hns.Contact_Overrun_Count__c = 2;
        system.assertEquals('Skipper John0 Doe0 & Charlie0 Carlson0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c6}));
        
        hns.Contact_Overrun_Count__c = 2;
        system.assertEquals('Skipper John0 & Jane0 Doe0 & Friends Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c2,c3}));
        
        hns.Contact_Overrun_Count__c = 2;
        system.assertEquals('Skipper John0 Doe0, Charlie0 Carlson0 & Friends Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c6,c3}));

        hns.Contact_Overrun_Count__c = 3;
        system.assertEquals('Skipper John0 & Jane0 Doe0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c2}));
        
        hns.Contact_Overrun_Count__c = 3;
        system.assertEquals('Skipper John0 Doe0 & Charlie0 Carlson0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c6}));
        
        hns.Contact_Overrun_Count__c = 3;
        system.assertEquals('Skipper John0, Jane0 & Sally0 Doe0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c2,c3}));
        
        hns.Contact_Overrun_Count__c = 3;
        system.assertEquals('Skipper John0 Doe0, Charlie0 Carlson0 & Sally0 Doe0 Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c6,c3}));

        hns.Contact_Overrun_Count__c = 3;
        system.assertEquals('Skipper John0 Doe0, Charlie0 Carlson0, Sally0 Doe0 & Friends Family',
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', new list<Contact>{c1,c6,c3,c4}));
    }
    
    /*********************************************************************************************************
    @description
    operation:
        several households with naming
        update name specs, and do a refreshAllHouseholdNaming 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void testRefreshAllHHNaming() {
        if (strTestOnly != '*' && strTestOnly != 'testRefreshAllHHNaming') return;

        Contact c1 = new Contact(
            Salutation = 'Skipper',
            Firstname = 'John',
            Lastname = 'DoeAA'
        );
        insert c1;
        c1 = [select Id, AccountId from Contact where Id = :c1.Id];
        system.assertNotEquals(null, c1.AccountId);
        
        Contact c2 = new Contact(
            Firstname = 'Jane',
            Lastname = 'DoeAA',
            AccountId = c1.AccountId
        );
        insert c2;
                
        Contact c3 = new Contact(
            Firstname = 'Sally',
            Lastname = 'SmithAA'
        );
        insert c3;
        c3 = [select Id, AccountId from Contact where Id = :c3.Id];
        system.assertNotEquals(null, c3.AccountId);

        Contact c4 = new Contact(
            Firstname = 'Sam',
            Lastname = 'SmithAA',
            AccountId = c3.AccountId
        );
        insert c4;
        
        // update our name formats
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        hns.Name_Connector__c = '&';
            

        // refresh all names
        Test.startTest();
        HH_HouseholdNaming.refreshAllHouseholdNaming(false);
        Test.stopTest();
        
        // verify the results
        Account hh1 = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c1.AccountId];
        system.assertEquals('HH - DoeAA, John & Jane Family', hh1.Name);    
        system.assertEquals('Skipper John & Jane DoeAA', hh1.npo02__Formal_Greeting__c);    
        system.assertEquals('John Dude & Jane Dude', hh1.npo02__Informal_Greeting__c);    

        Account hh2 = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c3.AccountId];
        system.assertEquals('HH - SmithAA, Sally & Sam Family', hh2.Name);    
        system.assertEquals('Sally & Sam SmithAA', hh2.npo02__Formal_Greeting__c);    
        system.assertEquals('Sally Dude & Sam Dude', hh2.npo02__Informal_Greeting__c);   
    }
     
    /*********************************************************************************************************
    @description
    operation:
        several households with custom naming
        update name specs, and do a refreshAllHouseholdNaming 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
        names that were previously customized do not get updated
    **********************************************************************************************************/            
    static testMethod void testRefreshAllHHNamingWithCustom() {
        if (strTestOnly != '*' && strTestOnly != 'testRefreshAllHHNamingWithCustom') return;
        
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettings();
    
        // turn off household naming        
        npo02__Households_Settings__c householdSettingsForTests = UTIL_CustomSettingsFacade.getHouseholdsSettingsForTests(
            new npo02__Households_Settings__c (
                npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR,
                npo02__Always_Rollup_to_Primary_Contact__c = false,
                npo02__Enable_Opp_Rollup_Triggers__c = true,
                npo02__Excluded_Account_Opp_Rectypes__c = null,
                npo02__Excluded_Account_Opp_Types__c = null,
                npo02__Excluded_Contact_Opp_Rectypes__c = null,
                npo02__Excluded_Contact_Opp_Types__c = null,
                npo02__Membership_Record_Types__c = null,
                npo02__Advanced_Household_Naming__c = false
            ));
        
        
        Contact c1 = new Contact(
            Salutation = 'Skipper',
            Firstname = 'John',
            Lastname = 'DoaBB'
        );
        insert c1;
        c1 = [select Id, AccountId from Contact where Id = :c1.Id];
        system.assertNotEquals(null, c1.AccountId);
        
        Contact c2 = new Contact(
            Firstname = 'Jane',
            Lastname = 'DoaBB',
            AccountId = c1.AccountId
        );
        insert c2;
                
        Contact c3 = new Contact(
            Firstname = 'Sally',
            Lastname = 'SmithBB'
        );
        insert c3;
        c3 = [select Id, AccountId from Contact where Id = :c3.Id];
        system.assertNotEquals(null, c3.AccountId);

        Contact c4 = new Contact(
            Firstname = 'Sam',
            Lastname = 'SmithBB',
            AccountId = c3.AccountId
        );
        insert c4;
        
        // give our household accounts some custom names
        Account hh1 = [select Id, Name, npe01__SYSTEM_AccountType__c, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c1.AccountId];
        system.assertEquals(CAO_Constants.HH_ACCOUNT_TYPE, hh1.npe01__SYSTEM_AccountType__c);
        system.assertEquals('DoaBB Household', hh1.Name);
        system.assertEquals(null, hh1.npo02__Formal_Greeting__c);
        system.assertEquals(null, hh1.npo02__Informal_Greeting__c);
        hh1.Name = 'My Custom HH Name';
        update hh1;
        
        Account hh2 = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c3.AccountId];
        hh2.Name = 'SmithBB Household';
        hh2.npo02__Informal_Greeting__c = 'The gang';
        update hh2;
                
        // update our name formats
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        hns.Name_Connector__c = '&';
        
        // turn on hh naming
        householdSettingsForTests.npo02__Advanced_Household_Naming__c = true;
        npo02__Households_Settings__c householdsSettings = UTIL_CustomSettingsFacade.getHouseholdsSettings();
        householdsSettings.npo02__Advanced_Household_Naming__c = true;

        // refresh all names
        Test.startTest();
        HH_HouseholdNaming.refreshAllHouseholdNaming(true);
        Test.stopTest();
        
        // verify the results
        hh1 = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c1.AccountId];
        system.assertEquals('My Custom HH Name', hh1.Name);    
        system.assertEquals('Skipper John & Jane DoaBB', hh1.npo02__Formal_Greeting__c);    
        system.assertEquals('John Dude & Jane Dude', hh1.npo02__Informal_Greeting__c);    

        hh2 = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c from Account where Id =:c3.AccountId];
        system.assertEquals('HH - SmithBB, Sally & Sam Family', hh2.Name);    
        system.assertEquals('Sally & Sam SmithBB', hh2.npo02__Formal_Greeting__c);    
        system.assertEquals('The gang', hh2.npo02__Informal_Greeting__c);   
    }

    /*********************************************************************************************************
    @description
    operation:
        many households with custom naming
        update name specs, and do a refreshAllHouseholdNaming 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void testRefreshAllHHNamingManyHH() {
        if (strTestOnly != '*' && strTestOnly != 'testRefreshAllHHNamingManyHH') return;
        
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = UTIL_CustomSettingsFacade.getContactsSettings();
    
        // turn off household naming        
        npo02__Households_Settings__c householdSettingsForTests = UTIL_CustomSettingsFacade.getHouseholdsSettingsForTests(
            new npo02__Households_Settings__c (
                npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR,
                npo02__Always_Rollup_to_Primary_Contact__c = false,
                npo02__Enable_Opp_Rollup_Triggers__c = true,
                npo02__Excluded_Account_Opp_Rectypes__c = null,
                npo02__Excluded_Account_Opp_Types__c = null,
                npo02__Excluded_Contact_Opp_Rectypes__c = null,
                npo02__Excluded_Contact_Opp_Types__c = null,
                npo02__Membership_Record_Types__c = null,
                npo02__Advanced_Household_Naming__c = false
            ));
        
        // create lots of contacts w/ households
        integer cHH = 200;  // CAUTION: this cannot be larger than our single batch size, or Salesforce gives a error in test mode not allowing multiple batches.
        list<Contact> listCon = UTIL_UnitTestData_TEST.CreateMultipleTestContacts(cHH);
        insert listCon;
                    
        // update our name formats
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}} Family';
        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        hns.Name_Connector__c = '&';
        
        // turn on hh naming
        householdSettingsForTests.npo02__Advanced_Household_Naming__c = true;
         npo02__Households_Settings__c householdsSettings = UTIL_CustomSettingsFacade.getHouseholdsSettings();
        householdsSettings.npo02__Advanced_Household_Naming__c = true;

        // refresh all names
        Test.startTest();
        HH_HouseholdNaming.refreshAllHouseholdNaming(true);
        Test.stopTest();
        
        // verify the results
        list<Account> listHH = [select Id, Name, npo02__Formal_Greeting__c, npo02__Informal_Greeting__c, 
            npe01__One2OneContact__c, npe01__One2OneContact__r.FirstName, npe01__One2OneContact__r.LastName from Account];
        for (Account hh : listHH) {
	        system.assertEquals('HH - ' + hh.npe01__One2OneContact__r.LastName + ', ' + hh.npe01__One2OneContact__r.FirstName + ' Family', hh.Name);   
	        system.assertEquals(hh.npe01__One2OneContact__r.FirstName + ' ' + hh.npe01__One2OneContact__r.LastName, hh.npo02__Formal_Greeting__c);    
	        system.assertEquals(hh.npe01__One2OneContact__r.FirstName + ' Dude', hh.npo02__Informal_Greeting__c);    
        }
    }

    /*********************************************************************************************************
    @description
    operation:
        1 anonymous contact in household 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void OneAnonymousContact() {
        if (strTestOnly != '*' && strTestOnly != 'OneContact') return;
        
        list<Contact> listCon = new list<Contact>();
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        
        hns.Household_Name_Format__c = '{!LastName} Family';
        system.assertEquals(label.npo02.HouseholdAnonymousName + ' Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Household_Name_Format__c = 'HH - {!LastName}, {!{!FirstName}}';
        system.assertEquals('HH - ' + label.npo02.HouseholdAnonymousName, ns.getExampleName(hns, 'Household_Name_Format__c', listCon));

        hns.Formal_Greeting_Format__c = '{!{!Salutation} {!FirstName}} {!LastName}';
        system.assertEquals(label.npo02.HouseholdAnonymousGreeting, ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));

        hns.Informal_Greeting_Format__c = '{!{!FirstName} Dude}';
        system.assertEquals(label.npo02.HouseholdAnonymousGreeting, ns.getExampleName(hns, 'Informal_Greeting_Format__c', listCon));

    }

    /*********************************************************************************************************
    @description
    operation:
        2 contact, same lastname in household, Account references 
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void TwoContactSameLastnameAccountReference() {
        if (strTestOnly != '*' && strTestOnly != 'TwoContactSameLastnameAccountReference') return;
        
        Account acc = new Account(
            Name = UTIL_UnitTestData_TEST.TEST_NAME,
            BillingCity = 'Seattle'
        );
        
        Contact conBoss = new Contact(
            Firstname = 'Big',
            Lastname = 'BossCC'
        );

        list<Contact> listCon = new list<Contact>();
        Contact c1 = new Contact (
            Account = acc,
            Salutation = 'Mr.',
            FirstName = 'John',
            LastName = 'DoeCC',
            ReportsTo = conBoss
        );
        acc.npe01__One2OneContact__r = c1;
        listCon.add(c1);

        Contact c2 = new Contact (
            Account = acc,
            Salutation = 'Mrs.',
            FirstName = 'Jane',
            LastName = 'DoeCC'
        );
        listCon.add(c2);
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettingsFacade.getHouseholdNamingSettings();
        hns.Name_Connector__c = '&';
        
        hns.Household_Name_Format__c = '{!LastName} {!Account.BillingCity} Family';
        system.assertEquals('DoeCC Seattle Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = '{!LastName} {!Account.npe01__One2OneContact__r.LastName} Family';
        system.assertEquals('DoeCC DoeCC Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = '{!{!Salutation}} {!Account.npe01__One2OneContact__r.FirstName} {!Account.npe01__One2OneContact__r.LastName} Family';
        system.assertEquals('Mr. & Mrs. John DoeCC Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = '{!{!Salutation}} {!FirstName} {!LastName} Family';
        system.assertEquals('Mr. & Mrs. John DoeCC Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
        
        hns.Household_Name_Format__c = '{!{!Salutation}} {!FirstName} {!LastName} (BossCC: {!Account.npe01__One2OneContact__r.ReportsTo.FirstName} {!Account.npe01__One2OneContact__r.ReportsTo.LastName}) Family';
        system.assertEquals('Mr. & Mrs. John DoeCC (BossCC: Big BossCC) Family', ns.getExampleName(hns, 'Household_Name_Format__c', listCon));
    }
    
    /*********************************************************************************************************
    @description
    operation:
        1 contact in household, namespace with multiple cross object references
    verify:
        HH Name, Formal Greeting, and Informal Greeting are correct
    **********************************************************************************************************/            
    static testMethod void OneContactXReferences() {
        if (strTestOnly != '*' && strTestOnly != 'OneContactXReferences') return;
        
        Account acc = new Account(Name=UTIL_UnitTestData_TEST.TEST_NAME);
        insert acc;

        Contact[] listCon = new Contact[] {
            new Contact (
                Salutation = 'Skipper',
                FirstName = 'John',
                LastName = 'DoeDD',
                Primary_Affiliation__c = acc.Id
            )
        };
        insert listCon;
        
        listCon = [select Id, Firstname, Lastname, Account.npe01__One2OneContact__r.Primary_Affiliation__r.Name from Contact];
        system.assertEquals(1, listCon.size());
               
        HH_NameSpec ns = new HH_NameSpec();
        Household_Naming_Settings__c hns = UTIL_CustomSettings_API.getHouseholdNamingSettings();
        
        // verify we handle multiple cross object references
        hns.Formal_Greeting_Format__c = '{!Account.npe01__One2OneContact__r.Primary_Affiliation__r.Name}';
        system.assertEquals(acc.Name, ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));
        
        // verify we handle multiple cross object references that encounter null lookups
        listCon[0].Primary_Affiliation__c = null;
        update listCon;
        listCon = [select Id, Firstname, Lastname, Account.npe01__One2OneContact__r.Primary_Affiliation__r.Name from Contact];
        system.assertEquals('', ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon));
        
        // now create bogus cross object reference to make sure we get an exception.
        try {
            hns.Formal_Greeting_Format__c = '{!Account.npe01__One2OneContact__r.Primary_Affiliation__c.Name}';
            ns.getExampleName(hns, 'Formal_Greeting_Format__c', listCon);
            system.assert(false);
        } catch (exception ex) {
            system.assert(ex.getMessage().contains('Invalid relationship Primary_Affiliation__c for Contact'));
        }
    }
}
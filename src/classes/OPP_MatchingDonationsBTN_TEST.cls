/*
    Copyright (c) 2011, Salesforce.org
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
* @author James Melville
* @date 2011 (2.1)
* @group Opportunity
* @description testing for matching donation button for opportunity
*/
@isTest(isParallel=True)
private class OPP_MatchingDonationsBTN_TEST {

    static testmethod void TestMatchingDonationPage()
    {
        Account testaccount = new Account(name=UTIL_UnitTestData_TEST.TEST_NAME);
        insert testaccount;

        Contact testcontact = UTIL_UnitTestData_TEST.getContact();
        testcontact.AccountId = testaccount.Id;
        insert testcontact;

        Opportunity testoppty = new Opportunity(
                AccountId = testaccount.Id,
                Closedate = System.today(),
                Amount = 100,
                Name=UTIL_UnitTestData_TEST.TEST_NAME,
                StageName = UTIL_UnitTestData_TEST.getClosedWonStage());
        insert testoppty;
        
        OpportunityContactRole testocr = new OpportunityContactRole(
                OpportunityId = testoppty.Id, ContactId = testcontact.Id, IsPrimary = true);
        insert testocr;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testoppty);
        OPP_MatchingDonationsBTN_CTRL DonationNewMatching = new OPP_MatchingDonationsBTN_CTRL(sc);
        
        DonationNewMatching.MatchingDonationPage();
    }
    
}
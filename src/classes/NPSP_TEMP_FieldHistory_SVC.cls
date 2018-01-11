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
public class NPSP_TEMP_FieldHistory_SVC {

    public static void trackRecordChanges(Map<Id, SObject> triggerNewMap, Map<Id, SObject> triggerOldMap) {
        List<NPSP_Field_History__c> histories = new List<NPSP_Field_History__c>();

        try {
            SObjectType objType = (triggerNewMap != null ? triggerNewMap.values()[0] : triggerOldMap.values()[0]).getSObjectType();
            String objName = objType.getDescribe().getName();

            Map<String, Schema.SObjectField> allFields = objType.getDescribe().fields.getMap();

            for (SObject s : (triggerNewMap != null ? triggerNewMap.values() : triggerOldMap.values())) {
                Id recordId = (Id) s.get('Id');
                if (Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) {
                    histories.add(new NPSP_Field_History__c(
                            Object_Name__c = objName,
                            Record_Id__c = recordId,
                            Account__c = (objName == 'Account' && !Trigger.isDelete ? recordId : null),
                            Contact__c = (objName == 'Contact' && !Trigger.isDelete ? recordId : null),
                            New_Value__c = 'Record ' + (Trigger.isInsert ? 'Created' : Trigger.isDelete ? 'Deleted' : 'Undeleted')
                    ));
                } else {
                    for (String f : allFields.keySet()) {
                        if (triggerOldMap == null || triggerNewMap == null || s.get(f) != triggerOldMap.get(recordId).get(f)) {
                            histories.add(new NPSP_Field_History__c(
                                    Object_Name__c = objName,
                                    Field_API_Name__c = f,
                                    Record_Id__c = recordId,
                                    Account__c = (objName == 'Account' && !Trigger.isDelete ? recordId : null),
                                    Contact__c = (objName == 'Contact' && !Trigger.isDelete ? recordId : null),
                                    Old_Value__c = getStringValue((triggerOldMap != null ? triggerOldMap.get(recordId) : null), allFields.get(f)),
                                    New_Value__c = getStringValue(s, allFields.get(f))
                            ));
                        }
                    }
                }
            }
        } catch (Exception ex) {
            // swallow the errors for now
        }

        if (histories.size() > 0) {
            database.insert(histories, false);
        }
    }

    private static String getStringValue(SObject obj, Schema.SObjectField f) {
        if (obj == null || obj.get(f) == null) {
            return null;
        } else if (f.getDescribe().getSoapType() == SoapType.BOOLEAN) {
            return (obj.get(f) == true ? 'TRUE' : 'FALSE');
        } else if (f.getDescribe().getType() == DisplayType.ENCRYPTEDSTRING) {
            return 'Encrypted Type Value';
        } else if (f.getDescribe().getType() == DisplayType.ADDRESS) {
            return 'Address Type Value';
        } else if (f.getDescribe().getType() == DisplayType.BASE64) {
            return 'Base64 Type Value';
        } else {
            return String.valueOf(obj.get(f));
        }
    }
}
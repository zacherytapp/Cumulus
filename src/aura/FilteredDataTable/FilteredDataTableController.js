({

    doInit: function(component, event, helper) {

        var columns = [
            {label: 'Opportunity Name', fieldName: 'Name', type: 'text'},
            {label: 'Stage', fieldName: 'StageName', type: 'text'},
            {label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
            {label: 'Primary Contact', fieldName: 'Primary_Contact__c', type: 'lookup'},
            {label: 'Amount', fieldName: 'Amount', type: 'currency'}
        ];

        component.set('v.columns', columns);
        var fields = [];
        columns.forEach(function(col){
           fields.push(col.fieldName);
        });

        console.log(fields);

        var sObjectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        var whereClause = component.get('v.whereClause');
        var childObject = component.get('v.childSObjectName');
        var relationshipField = component.get('v.relationshipField');

        var action = component.get('c.getData');

        action.setParams({
            sObjectName: sObjectName,
            fields: fields,
            recordId: recordId,
            whereClause: whereClause,
            childObject: childObject,
            relationshipField: relationshipField
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log(data);
                component.set('v.data', data);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    msg = errors[0].message;
                }
                //helper.showToast(component, 'error', 'Error: ', msg);
            }
        });

        $A.enqueueAction(action);
    }

})
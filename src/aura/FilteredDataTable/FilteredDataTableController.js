({

    doInit: function(component, event, helper) {

        var sObjectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        var whereClause = component.get('v.whereClause');
        var childObject = component.get('v.childSObjectName');
        var relationshipField = component.get('v.relationshipField');
        var fieldSet = component.get('v.fieldSet');

        var action = component.get('c.getData');

        action.setParams({
            sObjectName: sObjectName,
            recordId: recordId,
            whereClause: whereClause,
            childObject: childObject,
            relationshipField: relationshipField,
            fieldSet: fieldSet
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var response = JSON.parse(response.getReturnValue());
                component.set('v.data', response.data);
                component.set('v.columns', response.columns);
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
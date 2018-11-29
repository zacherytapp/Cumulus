({
    doInit: function(component, event, helper) {
        var action = component.get('c.getLayouts');

        action.setParams({
            layoutName: component.get('v.layoutName')
        });

        action.setCallback(this, function(response) {
            var returnValue = JSON.parse(response.getReturnValue());
            component.set('v.layoutSections', returnValue);
        });

        $A.enqueueAction(action);
    }
})
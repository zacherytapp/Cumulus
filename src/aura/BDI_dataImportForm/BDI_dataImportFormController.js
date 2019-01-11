({
    onLayoutSectionsChanged: function(component, event, helper) {
        var sections = component.get('v.layoutSections');
        var activeSections = sections.filter(s => s.editHeading).map(s => s.label);

        // wait till next render cycle to set this
        // why? https://salesforce.stackexchange.com/a/207116
        setTimeout($A.getCallback(() => component.set('v.activeSections', activeSections)));
    },

    handleLoad: function(component, event, helper) {
        helper.hideSpinner(component);
    },

    handleSubmit: function(component, event, helper) {
        helper.showSpinner(component);
        helper.checkRequired(component, event);
    },

    handleSuccess: function(component, event, helper) {
        helper.hideSpinner(component);
        helper.showSuccessToast();
        helper.resetForm(component);
    }
})
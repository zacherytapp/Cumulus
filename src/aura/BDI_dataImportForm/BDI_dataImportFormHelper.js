({
    showSpinner: function(component) {
        component.set('v.showSpinner', true);
    },

    hideSpinner: function(component) {
        component.set('v.showSpinner', false);
    },

    resetForm: function(component) {
        component.set('v.showForm', false);
        setTimeout($A.getCallback(() => component.set('v.showForm', true)));
    },

    showSuccessToast: function() {
        var toastEvent = $A.get('e.force:showToast');
        if(toastEvent) {
            toastEvent.setParams({
                "title": "Success!",
                "message": "The record has been saved successfully."
            });
            toastEvent.fire();
        }
    }
})
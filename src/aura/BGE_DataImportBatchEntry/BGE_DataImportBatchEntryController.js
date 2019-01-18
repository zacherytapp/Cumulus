({
    /**
     * @description: instantiates component. Only called when component is first loaded.
     */
    doInit: function (component, event, helper) {
        helper.getModel(component);
    },

    /**
     * @description: handles ltng:sendMessage from child component
     */
    handleMessage: function(component, event, helper) {
        var message = event.getParam('message');
        var channel = event.getParam('channel');

        if (channel === 'onSuccess') {
            helper.showToast(component, $A.get('$Label.c.PageMessagesConfirm'), $A.get('$Label.c.bgeGridGiftSaved'), 'success');
            helper.createEntryForm(component);
        } else if (channel === 'onCancel') {
            helper.createEntryForm(component);
        } else if (channel === 'setDonorType') {
            component.set('v.donorType', message.donorType);
        } else if (channel === 'hideFormSpinner') {
            helper.hideFormSpinner(component);
        } else if (channel === 'showFormSpinner') {
            helper.showFormSpinner(component);
        } else if (channel === 'onError') {
            helper.showToast(component, message.title, message.errorMessage, 'error');
        }
    }

})
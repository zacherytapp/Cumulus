({
    /**
     * @description: called during render to focus on open donation link if present and donation not selected
     */
    callFocus: function(component){
        let openDonationsLink = document.getElementById('selectOpenDonation');

        if (openDonationsLink && component.get('v.selectedDonation') == null) {
            openDonationsLink.focus();
        } else {
            let donorType = component.find('donorType');
            if (donorType) {
                donorType.focus();
            }
        }
    },

    /**
     * @description: alerts parent component that form needs to be reset
     */
    cancelForm: function (component, event, helper) {
        helper.sendMessage('onCancel', '');
        component.destroy();
    },

    /**
     * @description: listens for event listeners from other components
     */
    handleMessage: function (component, event, helper) {
        const message = event.getParam('message');
        const channel = event.getParam('channel');

        if (channel === 'selectedDonation') {
            helper.setDonation(component, message);
        }
    },

    /**
     * @description: alerts parent component that form is loaded
     */
    onFormLoad: function (component, event, helper) {
        helper.sendMessage('hideFormSpinner', '');
        component.find('donorType').focus();
    },

    /**
     * @description: alerts parent component that form is loaded
     */
    onDonorChange: function (component, event, helper) {
        helper.clearDonationSelectionOptions(component);
    },

    /**
     * @description: override submit function in recordEditForm to handle hidden fields and validation
     */
    onSubmit: function (component, event, helper) {
        event.preventDefault();
        component.set('v.pendingSave',true);
        var completeRow = helper.getRowWithHiddenFields(component, event);
        component.find('recordEditForm').submit(completeRow);
    },

    /**
     * @description: alerts parent component that record is saved and needs to be reset
     */
    onSuccess: function (component, event, helper) {
        var message = {'recordId': event.getParams().response.id};
        helper.sendMessage('onSuccess', message);
        component.destroy();
    },

    /**
     * @description: sets the donor type and alerts the parent. Used to circumvent the unhelpful labeling of Account1/Contact1.
     */
    setDonorType: function (component, event, helper) {
        let donorType = event.getSource().get('v.value');
        component.set('v.donorType', donorType);

        let message = {'donorType': donorType};
        helper.sendMessage('setDonorType', message);
        helper.clearDonationSelectionOptions(component);
    }

})
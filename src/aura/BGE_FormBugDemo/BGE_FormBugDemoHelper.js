({
    /**
     * @description: clears all info on user-selected open donation
     */
    clearDonationSelectionOptions: function(component) {
        component.set('v.selectedDonation', null);
    },

    /**
     * @description: sets the value of the selected donation
     */
    setDonation: function(component, selectedDonation) {
        component.set('v.selectedDonation', selectedDonation);
    },

    /**
     * @description: handle apex errors on the page by displaying a toast with the returned information
     */
    handleApexErrors: function(component, errors) {
        let message = $A.get('$Label.c.stgUnknownError');
        if (errors) {
            if (errors[0] && errors[0].message) {
                message = errors[0].message;
            }
        }
        this.sendMessage('onError', {title: $A.get('$Label.c.PageMessagesError'), errorMessage: message});
    },

    /**
     * @description: adds hidden and non-lightning:inputfield fields to the Data Import record before submitting.
     * @return: Object rowFields with hidden fields added
     */
    getRowWithHiddenFields: function (component, event) {
        let rowFields = event.getParam('fields');
        const labels = component.get('v.labels');

        const recId = component.get('v.recordId');
        rowFields[labels.batchIdField] = recId;

        // add donor type hidden fields
        const donorType = component.get('v.donorType');
        rowFields[labels.donationDonor] = donorType;

        // add any picklist fields manually, because they use lightning:select
        const dynamicInputFields = component.find('dynamicInputFields');
        const dataImportFields = component.get('v.dataImportFields');

        //dataImportFields and dynamicInputFields have the same order, so can loop both to get the value
        for (let i=0; i<dataImportFields.length; i++) {
            if (dataImportFields[i].options && dataImportFields[i].options.length > 0) {
                var fieldValue = dynamicInputFields[i].get('v.value');
                var fieldName = dataImportFields[i].name;
                rowFields[fieldName] = fieldValue;
            }
        }

        // assign opportunity/payment lookup and import status
        const selectedDonation = component.get('v.selectedDonation');
        const userSelectedMatch = $A.get('$Label.c.bdiMatchedByUser');
        const userSelectedNewOpp = $A.get('$Label.c.bdiMatchedByUserNewOpp');

        //set status fields to prevent dry run overwrite of lookup fields
        //else status fields are left null to allow for dry run in grid
        if (selectedDonation) {
            if (selectedDonation.attributes.type === 'Opportunity') {
                //selected opportunity; BDI will update the opportunity
                rowFields[labels.opportunityImportedLookupField] = selectedDonation.Id;
                rowFields[labels.opportunityImportedStatusField] = userSelectedMatch;
            } else {
                //selected payment; BDI will update the payment
                rowFields[labels.paymentImportedLookupField] = selectedDonation.Id;
                rowFields[labels.paymentImportedStatusField] = userSelectedMatch;
                rowFields[labels.opportunityImportedLookupField] = selectedDonation.npe01__Opportunity__c;
                rowFields[labels.opportunityImportedStatusField] = userSelectedMatch;
            }
        } else if (selectedDonation === '') {
            //create new opportunity if selectedDonation is set as empty string
            rowFields[labels.opportunityImportedStatusField] = userSelectedNewOpp;
        }

        return rowFields;
    },

    /**
     * @description: sends error toast to parent component notifying user of missing fields
     * @param missingFields: Array of missing fields
     */
    sendErrorToast: function(component, missingFields) {
        let channel = 'onError';
        let error = $A.get('$Label.c.exceptionRequiredField') + ' ' + missingFields.join(', ') + '.';
        let message = {title: $A.get('$Label.c.PageMessagesError'), errorMessage: error};
        this.sendMessage(channel, message);
    },

    /**
     * @description: send a message to other components
     */
    sendMessage: function (channel, message) {
        let sendMessage = $A.get('e.ltng:sendMessage');
        sendMessage.setParams({
            'channel': channel,
            'message': message
        });
        sendMessage.fire();
    },

    /**
     * @description: checks for Donor and other required fields and gathers error messages before submitting
     * @return: validity Object with Boolean for validity and an array of any missing fields to display
     */
    validateFields: function(component, rowFields) {
        return true;
    },

    /**
     * @description: checks for presence of fields that user has marked as required
     * @param rowFields: Object rowFields with updated hidden values
     * @return missingFields: list of any fields by label that are missing
     */
    verifyRequiredFields: function(component, rowFields) {
       return [];
    },

    /**
     * @description: checks for presence of a donor, which is always required
     * @param rowFields: Object rowFields with updated hidden values
     * @return hasDonor: Boolean to indicate if row has a donor
     */
    verifyRowHasDonor: function(component, rowFields) {
        return true;
    }

})
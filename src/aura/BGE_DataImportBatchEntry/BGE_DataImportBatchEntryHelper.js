({
    /**
     * @description: checks that user has all necessary permissions and then launches modal or displays error
     */
    checkFieldPermissions: function(component, event, helper) {
        var action = component.get('c.checkFieldPermissions');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.openBatchWizard(component, event);
            } else if (state === 'ERROR') {
                console.log(response.getError());
                this.handleApexErrors(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description: creates the form component
     */
    createEntryForm: function (component) {
        $A.createComponent(
            'c:BGE_FormBugDemo',
            {
                'aura:id': 'entryForm',
                'labels': component.get('v.labels'),
                'donorType': component.get('v.donorType'),
                'recordId': component.get('v.recordId'),
                'dataImportFields': component.get('v.dataImportFields')
            },
            function(newComponent, status, errorMessage){
                //Add the new component to the body array
                if (status === 'SUCCESS') {
                    var body = component.get('v.entryFormBody');
                    body.push(newComponent);
                    component.set('v.entryFormBody', body);
                }
                else if (status === 'INCOMPLETE') {
                    this.showToast(component, $A.get('$Label.c.PageMessagesError'), $A.get('$Label.c.stgUnknownError'), 'error');
                }
                else if (status === 'ERROR') {
                    this.showToast(component, $A.get('$Label.c.PageMessagesError'), errorMessage, 'error');
                }
            }
        );
    },

    /**
     * @description: retrieves the model information. If successful, sets the model and creates child component; otherwise alerts user.
     */
    getModel: function(component) {
        var action = component.get('c.getDataImportModel');
        action.setParams({batchId: component.get('v.recordId')});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = JSON.parse(response.getReturnValue());
                this.setModel(component, response);
                this.createEntryForm(component, response);
                component.find('forceRecordCmp').reloadRecord(true);
            } else {
                this.handleApexErrors(component, response.getError());
                this.hideFormSpinner(component);
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

    /**
     * @description: handles the display of errors from an apex callout
     * @param errors: list of potential errors passed back from apex
     */
    handleApexErrors: function(component, errors) {
        let message;
        if (errors && errors[0] && errors[0].message) {
            message = errors[0].message;
        } else {
            message = 'Unknown error';
        }
        this.showToast(component, $A.get('$Label.c.PageMessagesError'), message, 'error');
    },

    /**
     * @description: sets data import fields for dynamic use in the recordEditForm.
     * @param dataColumns: custom Column class data passed from the Apex controller.
     */
    setDataImportFields: function (component, dataColumns) {
        var dataImportFields = [];

        dataColumns.forEach(function(field){
            if (!field.readOnly) {
                dataImportFields.push({
                    label: field.label,
                    name: field.fieldName,
                    options: field.options,
                    required: field.required,
                    value: field.defaultValue
                });
            }
        });

        component.set('v.dataImportFields', dataImportFields);
    },

    /**
     * @description: sets data import fields to use dynamically in the recordEditForm.
     * @param model: full DataImportModel from the Apex controller
     */
    setModel: function (component, model) {
        component.set('v.labels', model.labels);
        this.setDataServiceFields(component, model.labels);
        this.setDataImportFields(component, model.columns);
        component.set('v.isNamespaced', Boolean(model.isNamespaced));
        component.set('v.isLoaded', true);
    },

    /**
     * @description: sets the data service fields to use the correct field labels depending on namespacing
     * @param labels: all labels for the app
     */
    setDataServiceFields: function(component, labels) {
        var fields = [];
        fields.push(labels.expectedCountField);
        fields.push(labels.expectedTotalField);
        fields.push(labels.requireTotalMatch);
        fields.push('Name');
        component.set('v.batchFields', fields);
    },

    /**
     * @description: displays standard toast to user based on success or failure of their action
     * @param title: title displayed in toast
     * @param message: body of message to display
     * @param type: configures type of toast
     */
    showToast: function(component, title, message, type) {
        var mode = (type === 'error') ? 'sticky' : 'pester';

        component.find('notifLib').showToast({
            'variant': type,
            'mode': mode,
            'title': title,
            'message': message
        });
    },

    /**
     * @description: shows spinner over BGE_FormBugDemo component
     */
    showFormSpinner: function (component) {
        var spinner = component.find('formSpinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    /**
     * @description: shows spinner over lightning:dataTable component
     */
    showSpinner: function (component) {
        var spinner = component.find('dataTableSpinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    /**
     * @description: hides spinner over BGE_FormBugDemo component
     */
    hideFormSpinner: function (component) {
        var spinner = component.find('formSpinner');
        $A.util.addClass(spinner, 'slds-hide');
    },

    /**
     * @description: hides spinner over lightning:dataTable component
     */
    hideSpinner: function (component) {
        var spinner = component.find('dataTableSpinner');
        $A.util.addClass(spinner, 'slds-hide');
    }

})
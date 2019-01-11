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
    },

    checkRequired: function(component, event) {
        var _self = this;
        var fieldMap = _self.getFieldMap(component);

        var inputFields = component.find('formInputField');

        var valid = inputFields.reduce((acc, inputCmp) => {
            var fieldName = inputCmp.get('v.fieldName');
            var fieldValue = inputCmp.get('v.value');
            var fieldDef = fieldMap[fieldName];
            var fieldRequired = fieldDef.behavior === 'Required';
            var fieldValid = !(fieldRequired && $A.util.isEmpty(fieldValue));

            return acc && fieldValid;
        });

        if(!valid) {
            event.preventDefault();
            _self.hideSpinner(component);
            console.error('form was not valid');
        }
    },

    getFieldMap: function(component) {
        var layoutSections = component.get('v.layoutSections');
        var fieldMap = {};

        layoutSections.forEach(section => {
            if(!$A.util.isEmpty(section.layoutColumns)) {
                section.layoutColumns.forEach(col => {
                    if(!$A.util.isEmpty(col.layoutItems)) {
                        col.layoutItems.forEach(item => {
                            fieldMap[item.field] = item;
                        });
                    }
                });
            }
        });

        return fieldMap;
    },


})
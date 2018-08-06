({
  next: function(component) {
    var currentStep = component.get('v.eventStepNumber');
    if (currentStep < 3) {
      component.set('v.eventStepNumber', currentStep + 1);
      component.set('v.step', 'step' + (currentStep + 1));
    }
  },
  back: function(component) {
    var currentStep = component.get('v.eventStepNumber');
    if (currentStep > 1) {
      component.set('v.eventStepNumber', currentStep - 1);
      component.set('v.step', 'step' + (currentStep - 1));
    }
  }
})
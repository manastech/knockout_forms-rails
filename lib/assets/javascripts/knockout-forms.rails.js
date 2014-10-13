(function() {
  var _global = this;
  ko.form = function(target, opts) {

    var options = opts || {},
        form = target,
        klazz = options.class || form.getAttribute('data-viewmodel'),
        model = options.model || form.getAttribute('data-model'),
        viewmodel,
        mapping;

    // Get constructor function based on name
    if (typeof(klazz) == 'string') {
      klazz = _global[klazz];
    }

    // Use viewmodel from options or create a new one
    if (options.viewmodel) {
      viewmodel = options.viewmodel;
    } else {
      viewmodel = new klazz;
      mapping = klazz.mapping || {};
      ko.mapping.fromJSON(model, mapping, viewmodel);
    }

    // Apply ko bindings
    ko.applyBindings(viewmodel, target);

  };
})(this);

module KnockoutForms::Rails::Helpers
  module FormHelper

    def knockout_form_for(object, options={}, &block)
      options[:builder]   ||= KnockoutForms::Rails::FormBuilder

      html = (options[:html] ||= {})

      html[:'class']          ||= "ko-form"
      html[:'data-model']     ||= (options.delete(:model) || object.to_json(options.delete(:model_options) || {}))
      html[:'data-viewmodel'] ||= object.class.to_s

      form_for(object, options, &block)
    end

  end
end

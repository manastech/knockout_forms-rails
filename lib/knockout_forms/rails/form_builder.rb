module KnockoutForms

  module Rails

    class FormBuilder < ActionView::Helpers::FormBuilder

      module Methods

        # Define attribute to bind based on input kind
        MAPPINGS = {
          value: %W(text_field number_field hidden_field),
          checked: %W(check_box radio_button)
        }

        def self.included(form)
          # Wrap all input fields so they add a KO value data bind
          MAPPINGS.each do |bind, fields|
            fields.each do |field_name|
              form.send(:define_method, field_name) do |name, *args|
                opts = args.extract_options!.with_indifferent_access
                add_data_bind(opts, bind, name)
                super(name, *(args << opts))
              end
            end
          end
        end

        # Handle select differently due to the html opts
        def select(method, choices = nil, options = {}, html_options = {}, &block)
          html_options = html_options.with_indifferent_access
          add_data_bind(html_options, 'value', method)
          super(method, choices, options, html_options, &block)
        end

        def fields_for(collection_name, options={}, &block)
          options = options.with_indifferent_access
          empty_child = options[:empty] || object.association(collection_name).klass.new
          collection = options[:collection] || collection_name
          # Run fields_for with a single empty child that will act as the KO template for each item
          # and use foreach data bind to delegate the iteration to KO
          @template.content_tag(:div,
              super(collection_name, [empty_child], options.merge(child_index: ""), &block),
            :'data-bind' => "foreach: #{collection}",
            :'data-collection' => collection,
            :'class' => "children-collection #{collection}-collection")
        end

        def add_item(collection_name, options={})
          options = options.with_indifferent_access
          child_klass = object.association(collection_name).klass
          label = options.delete(:label) || "Add new #{child_klass.model_name.singular}"
          handler = add_item_handler(collection_name, options)
          action(label, handler, options)
        end

        def add_item_handler(collection_name, options={})
          options = options.with_indifferent_access
          child_klass = object.association(collection_name).klass

          label = options.delete(:label) || "Add new #{child_klass.model_name.singular}"
          viewmodel_collection = options.delete(:collection) || collection_name
          viewmodel = options.delete(:child_class) || child_klass.name

          # Create an empty child to inject attributes via KO mapping
          model = options.delete(:model) || child_klass.new.to_json

          # Create new child viewmodel augmented with model attributes and
          # automatically add to viewmodel collection on click
          options[:handler] || <<-JS_HANDLER
            function(data, event) {
              var viewmodel = new #{viewmodel}(data);
              ko.mapping.fromJS(#{model}, {}, viewmodel);
              #{viewmodel_collection}.push(viewmodel);
            };
          JS_HANDLER
        end

        def action(label, action, options={})
          add_data_bind(options, 'click', action)
          @template.link_to(label, '#', options)
        end

        private

        def add_data_bind(opts, key, value)
          unless opts.delete(:bind) == false
            opts['data-bind'] = [opts['data-bind'], "#{key}: #{value}"].compact.join(', ')
          end
        end

      end

      include Methods

    end

  end

end

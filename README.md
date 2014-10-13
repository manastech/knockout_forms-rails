# KnockoutForms::Rails

Knockoutjs powered form builder for Rails. This gem provides a `knockout_form_for` helper that creates forms automatically bound to a viewmodel created for your model via the mapping plugin.

## Why?

There was a large gap between how Rails standard forms and knockoutjs based forms are written: where the former make use of handy form builders, the latter require the markdown the be manually set up and wired with `data-bind` attributes, even if the viewmodel is rather simple.

This gem intends to bridge this gap by allowing a Rails form to be easily converted in a knockoutjs aware one, by allowing you to keep using form builders while automatically handling data binding under the covers.

That being said, the gem provides several endpoints for customisation, making it easy to insert your custom logic whenever needed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'knockout_forms-rails'
```

And add the following directive to your Javascript manifest file (application.js):

```javascript
//= require knockout-forms.rails
```

## Dependencies

This gem requires both knockoutjs and the knockoutjs mapping plugin. The easiest way to do this is via the [knockoutjs-rails gem](https://github.com/jswanner/knockoutjs-rails); though it is not listed as a dependency in case you want to manage your javascript libraries somehow else.

## Example application

There is an [example application](https://github.com/spalladino/knockout_forms-rails-example) available with a simple [User form](https://github.com/spalladino/knockout_forms-rails-example/blob/master/app/views/users/_form.html.erb) and a complex [Questionnaire form](https://github.com/spalladino/knockout_forms-rails-example/blob/master/app/views/questionnaires/_form.html.erb) with a N-to-1 relation to Questions.

## Usage

This gem provides a `KnockoutForms::Rails::FormBuilder` class, accessible via the `knockout_form_for` method, which must be bound invoking the javascript `ko.form(f)` method with a reference to it.

### Basic usage

The easiest example is to use the `knockout_form_for` helper instead of a regular form, and invoke `ko.form()` on page load for the form you want to bind. For example, given a simple `user` model:

```haml
= knockout_form_for(@user) do |f|

  .form-group
    = f.label :name
    = f.text_field :name

  .form-group
    = f.label :registered
    = f.check_box :registered

  .form-group{"data-bind" => "visible: registered"}
    = f.label :email
    = f.text_field :email

  .actions
    = f.submit class: 'btn btn-primary'
```

The `data-bind` with value `visible: registered` on the `email` field. This will display the email field only if the registered property is set to true.

The gem automatically creates a viewmodel for you based on the `user` model via the mapping plugin, bind it to the form, and set `value` bindings for all inputs.

To ensure `ko-forms` are always initialized, you can use this script:

```coffeescript
$ ->
  $('.ko-form').each ->
    ko.form this
```

### Providing your own viewmodel

You can use your own viewmodel with your custom functions instead of an empty object. There are a few ways of doing this:

-   The easiest way is to simple define a javascript class in the global scope with the same name as the model, which will be picked up by the `ko.form()` function:


        class @Questionnaire
          preview:
            alert "Questionnaire: #{@title()}"


    You can then invoke the `preview` function in your viewmodel class from `click` handler, or using the `action` method in the form builder:

        = f.action 'Preview question', 'preview'

-   The other option is to manually provide a reference to the class in the `ko.form()` method invocation:

        class Questionnaire
          preview:
            alert "Questionnaire: #{@title()}"

        $ ->
          form = $('.questionnaire-ko-form')[0]
          ko.form form, class: Questionnaire

-   Alternatively, you can provide your own already populated viewmodel instance, in which case the `model` information will not be used and the mapping plugin will not be required. Just pass a `viewmodel` option to the `ko.form` function to do this:

        questionnaire = new Questionnaire()
        ko.form form, viewmodel: questionnaire

-   Furthermore, you can skip using the `ko.form` function altogether and simply run a simple `ko.applyBindings` to the form using a viewmodel of your choice.

### Mapping options

A custom mapping for your viewmodel can be provided as well. This will be passed directly as an argument to the `ko.mapping.fromJSON` invocation used to populate your viewmodel. It can be specified in the following ways:

-   If you have supplied a viewmodel class and it has a `mapping` attribute, then it will be used automatically:

        class Questionnaire
          @mapping:
            copy: ["description"]

-   As an option to the `ko.form` method:

        ko.form form, mapping: myCustomMapping

### Model data

The model used to populate the knockout viewmodel is the result of a `to_json` call to the Rails model. If there are certain properties you want to include that are not ActiveRecord fields, you need to specify that when creating the form.

-   Add the fields to be included as a `model_options` option in the `knockout_form_for` declaration:

        model_options: { include: :custom_field }

-   Or directly specify the model you want to be used via `model`:

        model: @questionnaire.to_json({ include: :custom_field })

Keep in mind that the model information is not required if you specify your own viewmodel via the `viewmodel` option in the `ko.form` invocation.

### Nested forms

Nested 1-to-N forms can be easily set up, and was one of the main drivers in the development of this gem. They do require some custom options to be properly handled, which are listed next. Refer to the questionnaire form (a questionnaire has_many questions) in the example application for a complete reference.

-   Child elements must be included in the `model` when serializing it to populate the viewmodel, otherwise the children will not be included when editing an instance of the parent:

        model_options: { include: :questions }

-   In order to use custom viewmodel classes for both the parent and child elements, a custom mapping needs to be set up:

        class @Question

        class @Questionnaire
          @mapping:
            questions:
              create: (opts) ->
                ko.mapping.fromJS(opts.data, {}, new Question())

    This will instruct the knockout mapping plugin to use a new instance of Question for each question in questionnaire that needs to be populated.

-   The `fields_for` method in the form builder is overriden so it will use a `foreach` binding to display one template for each child. A `hidden_field` for the `id` must be included to keep track of existing instances.

        = f.fields_for :questions do |g|

          %h3 Question
          = g.hidden_field :id

          .form-group
            = g.label :text
            = g.text_field :text

    Inside the `fields_for` body, all the markdown will be rendered once per question, and will be bound to the corresponding instance.

-   A method `add_item` is provided in the form builder for convenience, which will attempt to automatically add an empty instance of the specified child viewmodel, populated from an empty child using the mapping plugin:

        = f.add_item :questions, label: "Add new question", viewmodel: 'Question'

    The usage of this helper is complete optional, as adding new items to the collection can be handled manually, by writing your own `addQuestion` function in the `Questionnaire` class and invoking it as:

        = f.action "Add new question", 'addQuestion'

-   As with all nested forms, remember to include the `accepts_nested_attibutes_for` option in your model, so the `fields_for` generated parameters will work correctly, which need to be permitted in the controller as well.

### Using your own form builder

All methods in the form builder are provided in a mixin `KnockoutForms::Rails::FormBuilder::Methods` which you can include to your own FormBuilder to have it render knockout based forms.

## Internals

The `KnockoutForms::Rails::FormBuilder` is the core of this gem. It overrides standard input helpers by adding a `data-bind` mapping to either their value or checked state, so they are automatically bound to the viewmodel attributes.

The input helpers currently supported are the following, you are welcome to send a pull request with your own:

- `text_field`
- `number_field `
- `hidden_field`
- `check_box `
- `radio_button`
- `select`

The counterpart of the form builder is the javascript code that binds it: the `knockout-forms.rails.js` script contains the `ko.form` function that either directly binds the form to the chosen viewmodel, or creates the viewmodel using the `model` JSON representation and the mapping plugin.

## Contributing

1. Fork it ( https://github.com/manastech/knockout_forms-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

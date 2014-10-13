require "knockout_forms/rails/version"
require "knockout_forms/rails/form_builder"
require "knockout_forms/rails/helpers/form_helper"

module KnockoutForms
  module Rails
    class Engine < ::Rails::Engine
      initializer 'knockout_forms-rails.initialize' do
        ActiveSupport.on_load(:action_view) do
          include KnockoutForms::Rails::Helpers::FormHelper
        end
      end
    end
  end
end

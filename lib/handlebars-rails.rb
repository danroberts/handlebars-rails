require 'handlebars-rails/version'
require 'handlebars-rails/tilt'
require 'handlebars-rails/template_handler'
require 'handlebars'

module Handlebars
  class Rails < ::Rails::Engine

    unless config.respond_to?(:handlebars)
      config.handlebars = ActiveSupport::OrderedOptions.new
    end
    config.handlebars.override_ember_precompiler = false
    
    initializer 'handlebars.handler.setup', :before => :add_view_paths do |app|
      app.paths['app/views'] << 'app/templates'
      ActiveSupport.on_load(:action_view) do
        ActionView::Template.register_template_handler(:hbs, ::Handlebars::TemplateHandler)
      end
    end
    
    initializer "sprockets.handlebars", :after => "sprockets.environment", :group => :all do |app|
      next unless app.assets

      app.assets.append_path 'app/templates'
      app.assets.register_engine('.hbs', Tilt)
      logger = Logger.new(STDOUT)
      logger.debug("making link for assets registration engine");
    end
  end
end
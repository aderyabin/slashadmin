module SlashAdmin
  class Engine < Rails::Engine
    engine_name 'slashadmin'
    isolate_namespace SlashAdmin
    
    config.admin_controller_paths = [ "app/controllers/admin" ]
    config.admin_modules          = [ "tablette", "show_for", "simple_form" ]
    config.authentication_method  = :authenticate_admin_user!
    config.current_user_method    = :current_admin_user
    config.brand                  = "SlashAdmin"
    config.brand_url              = { :controller => "dashboard", :action => "index" }
    
    initializer "slashadmin.preload_controllers", :after => :after_initialize do |app|
      config.admin_modules.each do |name|
        require "slash_admin/modules/#{name}"
      end

      collect_controller_paths do |path|
        unless app.config.cache_classes
          ActiveSupport::Dependencies.autoload_paths << path.to_s
        end
      end

      load_controllers
      ActionDispatch::Reloader.to_prepare &method(:load_controllers)
    end

    private

    def load_controllers
      unless defined? SlashAdmin::Controller
        Rails.logger.info "Reloading SlashAdmin controllers"
        collect_controller_paths do |path|
          Dir.glob(path.join("**/*.rb")).each do |file|
            require_dependency file
          end
        end
      end
    end

    def collect_controller_paths(&block)
      roots = Rails::Application::Railties.engines.map { |engine| engine.config.root }
      roots << Rails.root
      
      roots.each do |root|
        config.admin_controller_paths.each do |controller_path|
          path = root.join(controller_path)
          if path.exist?
            yield path
          end
        end
      end
    end
  end
end

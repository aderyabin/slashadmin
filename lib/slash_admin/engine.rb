module SlashAdmin
  class Engine < Rails::Engine
    engine_name 'slashadmin'
    isolate_namespace SlashAdmin
    
    config.admin_controller_paths = [ "app/controllers/admin" ]
    config.admin_modules          = [ "grid_fu", "show_for", "simple_form" ]
    config.authentication_method  = :authenticate_admin_user!
    config.current_user_method    = :current_admin_user
    config.restrict_model         = false
    config.unrestrict_model       = false
    
    initializer "slashadmin.preload_controllers", :after => :after_initialize do |app|
      config.admin_modules.each { |name| require "slash_admin/#{name}" }
    
      collect_controller_paths do |path|
        unless app.config.cache_classes
          ActiveSupport::Dependencies.autoload_paths << path.to_s
        end
  
        Dir.glob(path.join("**/*.rb")).each do |file|
          require_dependency file
        end
      end
    end

    private

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

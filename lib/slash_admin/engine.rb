module SlashAdmin
  class Engine < Rails::Engine
    engine_name 'slashadmin'
    isolate_namespace SlashAdmin
    
    config.admin_controller_paths = [ "app/controllers/admin" ]
    
    initializer "slashadmin.preload_controllers", :after => :after_initialize do |app| 
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

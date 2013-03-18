module SlashAdmin
  class Engine < Rails::Engine
    engine_name 'slashadmin'
    isolate_namespace SlashAdmin
    
    config.admin_controller_paths = [ "app/controllers/admin" ]
    config.admin_routes = [
      [ :get,    "",          :index,  ":entitys"     ],
      [ :post,   "",          :create, nil            ],
      [ :get,    "/new",      :new,    "new_:entity"  ],
      [ :get,    "/:id/edit", :edit,   "edit_:entity" ],
      [ :get,    "/:id",      :show,   ":entity"      ],
      [ :put,    "/:id",      :update,  nil           ],
      [ :delete, "/:id",      :destroy, nil           ]
    ]
    
    initializer "slashadmin.preload_controllers", :after => :after_initialize do |app|
      collect_controller_paths do |path|
        Dir.glob(path.join("**/*.rb")).each do |file|
          require_dependency file
        end
      end

      route_list = config.admin_routes
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

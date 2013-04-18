SlashAdmin.on_module_event(:created_routes) do
  helpers = SlashAdmin::Engine.routes.url_helpers

  helpers.methods.each do |name|
    if name =~ /_(url|path)$/
      method = ->(*args) do
        ActiveSupport::Deprecation.warn("admin_#{name} URL helper is deprecated. Use #{name} instead.")
        __send__ name, *args
      end

      helpers.send :define_method, "admin_#{name}", &method 
      helpers.send :define_singleton_method, "admin_#{name}", &method
    end
  end
end
SlashAdmin::Engine.routes.draw do
  # TODO: proper pages
  get '', :controller => "dashboard", :action => "index"
  
  SlashAdmin.each_controller do |const|
    resource = const.slashadmin_model_name.underscore

    routing = const.new.slashadmin_routing

    resources "#{resource}s", routing.resource_options.merge(:controller => "admin_#{resource}") do
      if routing.batch_actions?
        post 'batch', :on => :collection, :action => "dispatch_batch"
      end

      routing.custom_actions.each do |action|
        send action.method, action.name, action.options
      end
    end
  end
end

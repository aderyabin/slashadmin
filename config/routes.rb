SlashAdmin::Engine.routes.draw do
  SlashAdmin.each_controller do |const|
    resource = const.slashadmin_model.name.underscore
      
    resources "#{resource}s", :controller => "admin_#{resource}" do
      post 'batch', :on => :collection, :action => "dispatch_batch"
    end
  end
end

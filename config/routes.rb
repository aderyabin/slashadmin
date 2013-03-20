SlashAdmin::Engine.routes.draw do
  SlashAdmin.constants.each do |name|
    const = SlashAdmin.const_get(name)
    if const.is_a?(Class) && const < SlashAdmin::Controller
      resource = const.slashadmin_model.name.underscore
      
      resources "#{resource}s", :controller => "admin_#{resource}"
    end
  end
end

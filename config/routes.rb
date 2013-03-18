SlashAdmin::Engine.routes.draw do
  puts "loading engine routes"
  SlashAdmin::Controller.slashadmin_controllers.each do |controller|
    
    name = controller.slashadmin_model.name.underscore
    prefix = "/#{name}s"
    SlashAdmin::Engine.config.admin_routes.each do |(method, path, action, helper_template)|
      options = {}
    
      options[:to] = controller.action(action)
      unless helper_template.nil?
        options[:as] = helper_template.sub(/:entity/, name)
      end
      
      send method, "/#{name}s#{path}", options
    end
  end
end

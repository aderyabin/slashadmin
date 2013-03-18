SlashAdmin::Engine.routes.draw do
  SlashAdmin.constants.each do |name|
    if name =~ /^Admin(.+)Controller/
      resource = $1.underscore
      
      resources resource, :controller => "admin_#{resource}"
    end
  end
end

SlashAdmin.view_helper(:Config) do
    def self.config_helper(*names)
      names.each do |name|
        define_method(name) do 
          value = SlashAdmin::Engine.config.send(name)
          if value.respond_to? :call
            instance_exec &value
          else
            value
          end
        end
      end
    end
  
    config_helper :brand, :brand_url
end
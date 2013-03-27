module SlashAdmin
  module Authentication
    extend ActiveSupport::Concern
   
    included do
      before_filter :slashadmin_authenticate!
    end
  
    protected
  
    def slashadmin_authenticate!
      helper =  Engine.config.authentication_method
      
      send helper unless helper == false
    end

    def slashadmin_current_user
      helper = Engine.config.current_user_method
      
      if helper == false
        nil
      else
        send helper
      end
    end

    
  end
end
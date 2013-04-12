module SlashAdmin
  module Restrictions
    extend ActiveSupport::Concern
   
    protected

    def slashadmin_restrict(model = self.class.slashadmin_model)
      helper = Engine.config.restrict_model
      
      if helper == false
        model
      else
        instance_exec model, &helper
      end
    end
  
    def slashadmin_unrestrict(model)
      helper = Engine.config.unrestrict_model
      
      if helper == false
        model
      else
        instance_exec model, &helper
      end
    end
  end
end
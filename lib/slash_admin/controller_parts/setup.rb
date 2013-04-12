module SlashAdmin
  module Setup
    extend ActiveSupport::Concern
  
    included do
      delegate :slashadmin_model_name, :slashadmin_model, :to => :class
    end
  
    module ClassMethods
      attr_reader :slashadmin_model
      
      def admin(model)
        @slashadmin_model = model
        batch_model model

        include_admin_set SlashAdmin::AdminSets::Base

        compat = Engine.config.compatibility
        unless compat.nil?
          include_admin_set SlashAdmin::AdminSets.const_get(compat.to_s.camelize)
        end
        
        alias_name = "Admin#{model.name}Controller"
        SlashAdmin.const_set alias_name, self
        
        unless Rails.application.config.cache_classes
          ActiveSupport::Dependencies.autoloaded_constants << self.name << "SlashAdmin::#{alias_name}"
        end

        self.initialize_slashadmin_controller
      end
      
      def slashadmin_model_name
        @slashadmin_model.name
      end
    
      private

      def include_admin_set(set)
        set.constants.each do |constant|
          include set.const_get(constant)
        end
      end
    end
  end
end
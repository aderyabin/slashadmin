module SlashAdmin
  module Setup
    extend ActiveSupport::Concern
  
    included do
      attr_reader :slashadmin_model
      delegate :slashadmin_model, :to => :class
    end
  
    module ClassMethods
      attr_reader :slashadmin_model

      def admin(model)
        @slashadmin_model = model
        batch_model model

        include_admin_set SlashAdmin::Base
        
        alias_name = "Admin#{model.name}Controller"
        SlashAdmin.const_set alias_name, self
        
        unless Rails.application.config.cache_classes
          ActiveSupport::Dependencies.autoloaded_constants << self.name << "SlashAdmin::#{alias_name}"
        end

        self.initialize_slashadmin_controller
      end
    
      private

      def include_admin_set(set)
        set.constants(false).each do |constant|
          include(set.const_get(constant))
        end
      end
    end
  end
end

module SlashAdmin
  class Controller < ApplicationController
    include BatchActions

    class << self
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
      end
    
      private

      def include_admin_set(set)
        set.constants(false).each do |constant|
          include(set.const_get(constant))
        end
      end
    end

    def slashadmin_model
      self.class.slashadmin_model
    end

    def render_default_index_actions(object)
      render_to_string(:layout => false, :partial => "admin/index/default_actions", :locals => { :object => object }).html_safe
    end
  
    protected

    def fetch_index
      slashadmin_model.all
    end
  
    def fetch_show
      slashadmin_model.find(params[:id])
    end
  end
end

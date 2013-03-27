module SlashAdmin
  module DSL
    extend ActiveSupport::Concern
    
    DSL_METHODS = [ :slashadmin_index, :slashadmin_show, :slashadmin_form, :slashadmin_permit_params, :slashadmin_menu, :slashadmin_filters ]
    
    included do
      delegate *DSL_METHODS, :to => :class
    end
  
    module ClassMethods
      attr_accessor *DSL_METHODS
    
      def index(&block); self.slashadmin_index = block; end
      def show(&block); self.slashadmin_show = block; end
      def form(&block); self.slashadmin_form = block; end
      def permit_params(*args); self.slashadmin_permit_params = args; end
      def menu(options = {}); self.slashadmin_menu = options; end
      def filter(name, options = {})
        slashadmin_filters << {
          :name       => name,
          :as         => nil,
          :collection => nil,
          :label      => nil
        }.merge!(options)
      end
    end
  end
end

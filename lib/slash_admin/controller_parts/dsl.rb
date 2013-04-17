module SlashAdmin
  module DSL
    extend ActiveSupport::Concern

    SLASHADMIN_DSL_METHODS = [
      :slashadmin_index, :slashadmin_show, :slashadmin_form, :slashadmin_permit_params, :slashadmin_routing_block,
      :slashadmin_layout_block
    ]
    
    included do
      class_eval(SLASHADMIN_DSL_METHODS.map { |method| "def #{method}; self.class.#{method}; end" }.join("\n"))
    end

    module ClassMethods
      attr_accessor *SLASHADMIN_DSL_METHODS

      def index(&block)
        @slashadmin_index = block
      end

      def show(&block)
        @slashadmin_show = block
      end

      def form(options = {}, &block)
        @slashadmin_form = SlashAdmin::Form.new(options, block)
      end

      def routing(&block)
        @slashadmin_routing_block = block
      end

      def layout(&block)
        @slashadmin_layout_block = block
      end

      def permit_params(*args)
        @slashadmin_permit_params = args
      end
    end

    def slashadmin_routing
      SlashAdmin::Routing.build(self, &slashadmin_routing_block)
    end

    def slashadmin_layout
      SlashAdmin::Layout.build(self, &slashadmin_layout_block)
    end 
  end
end

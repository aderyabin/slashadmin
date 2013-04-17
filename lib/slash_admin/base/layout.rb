module SlashAdmin
  class Layout
    class Scope
      attr_reader :label, :name, :options

      def initialize(label, name, options)
        @label = label
        @name = name
        @options = options
      end
    end

    class Filter
      attr_reader :attribute, :options

      def initialize(attribute, options)
        @attribute = attribute
        @options = options
      end
    end

    class ActionItem
      attr_reader :options, :block

      def initialize(options, block)
        @options = options
        @block = block
      end
    end

    attr_accessor :helper
    attr_reader :menu_options, :scopes, :filters, :action_items

    def initialize
      @menu_options = {}
      @scopes = []
      @filters = []
      @action_items = []
    end

    def menu(options = {})
      @menu_options = options
    end

    def scope(label, name, options = {})
      @scopes << Scope.new(label, name, options)
    end

    def filter(attribute, options = {})
      @filters << Filter.new(attribute, options)
    end

    def action_item(options = {}, &block)
      @action_items << ActionItem.new(options, block)
    end

    def self.build(helper = nil, &block)
      instance = self.new
      instance.helper = helper
      instance.instance_exec &block if block_given?
      instance.helper = nil
      instance
    end

    def respond_to?(method)
      super || (!@helper.nil? && @helper.respond_to?(method))
    end

    def method_missing(method, *args, &block)
      if !@helper.nil? && @helper.respond_to?(method)
        @helper.__send__ method, *args, &block
      else
        super
      end
    end
  end
end

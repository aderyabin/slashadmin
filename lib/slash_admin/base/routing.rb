module SlashAdmin
  class Routing
    class Action
      attr_reader :name, :method, :options, :title, :block

      def initialize(on, name, options, &block)
        @name = name
        @options = options.merge({ :on => on })
        @method = @options.delete(:method) { :get }
        @title = @options.delete(:title)
        @block = block
      end
    end

    attr_accessor :helper
    attr_reader :resource_options, :custom_actions

    def initialize
      @resource_options = {}
      @custom_actions = []
      @batch_actions = true
    end

    def action_allowed?(action)
      only = @resource_options[:only]
      return Array(only).include?(action) unless only.nil?

      without = @resource_options[:without]
      return !Array(without).include?(action) unless without.nil?

      true
    end

    def default_actions(options = {})
      @resource_options = options
    end

    def member_action(name, options = {}, &block)
      @custom_actions << Action.new(:member, name, options, &block)
    end

    def collection_action(name, options = {}, &block)
      @custom_actions << Action.new(:collection, name, options, &block)
    end

    def batch_actions?
      @bath_actions
    end

    def batch_actions(enabled = true)
      @batch_actions = enabled
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

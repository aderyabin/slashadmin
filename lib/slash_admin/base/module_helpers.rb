module SlashAdmin
  class << self
    def extension(module_set, name, &block)
      mod = Module.new 
      SlashAdmin::AdminSets.const_get(module_set).const_set(name, mod)

      mod.send :extend, ActiveSupport::Concern
      mod.class_exec(&block)

      check_for_class_methods
    end

    def shim_for(klass, &block)
      mod = Module.new
      SlashAdmin::Shims.const_set(generate_module_name, mod)

      mod.send :extend, ActiveSupport::Concern
      mod.send :extend, SlashAdmin::Shim
      mod.send :include_into, klass

      mod.class_exec(&block)

      check_for_class_methods
    end

    def view_helper(name, &block)
      mod = Module.new
      SlashAdmin::ViewHelpers.const_set(name, mod)

      mod.send :extend, ActiveSupport::Concern
      mod.class_exec(&block)

      check_for_class_methods

      if defined? SlashAdmin::ApplicationHelper
        SlashAdmin::ApplicationHelper.send :include, mod
      end
    end

    def reinclude_view_helpers!
      SlashAdmin::ViewHelpers.constants.each do |name|
        helper = SlashAdmin::ViewHelpers.const_get(name)

        SlashAdmin::ApplicationHelper.send :include, helper
      end
    end

    def each_controller(&block)
      self.constants.each do |name|
        const = self.const_get(name)
        if const.is_a?(Class) && const < SlashAdmin::Controller
          yield const
        end
      end
    end

    def send_module_event(name, *args)
      @module_event_table ||= {}
      chain = @module_event_table.fetch(name, [])
      chain.each { |block| block.call *args }
    end

    def on_module_event(name, &block)
      @module_event_table ||= {}

      chain = @module_event_table[name]
      if chain.nil?
        chain = []
        @module_event_table[name] = chain
      end

      chain << block
    end
    
    private

    def generate_module_name
      @mod_id ||= 0
      @mod_id += 1

      "AnonMod#{@mod_id}"
    end

    def check_for_class_methods
      raise ArgumentError, "Use module self::ClassMethods, not module ClassMethods" if Object.const_defined? :ClassMethods
    end
  end
end

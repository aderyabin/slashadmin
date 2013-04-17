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

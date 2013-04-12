module SlashAdmin
  class << self
    def extension(module_set, name, &block)
      mod = Module.new do
        extend ActiveSupport::Concern
      end

      SlashAdmin::AdminSets.const_get(module_set).const_set(name, mod)

      mod.instance_exec(&block)
    end

    def shim_for(klass, options = {}, &block)
      name = generate_module_name

      mod = Module.new do
        extend ActiveSupport::Concern
        extend SlashAdmin::Shim

        include_into klass, options
      end

      SlashAdmin::Shims.const_set("Shim#{@shim_id}", mod)

      mod.instance_exec(&block)
    end

    def view_helper(name, &block)
      mod = Module.new do
        extend ActiveSupport::Concern
      end

      SlashAdmin::ViewHelpers.const_set(name, mod)

      mod.instance_exec(&block)

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
  end
end

module SlashAdmin
  class << self
    def register(model, &block)
      Class.new(SlashAdmin::Controller) do
        admin model
        instance_exec &block
      end
    end

    def compatible_with?(engine)
      SlashAdmin::Engine.config.compatibility == engine
    end

    def configure(&block)
      yield SlashAdmin::Engine.config
    end
  end
end

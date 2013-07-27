module SlashAdmin
  class << self
    def register(model, &block)
      Class.new(SlashAdmin::Controller) do
        admin model
        instance_exec &block
      end
    end
    
    def configure(&block)
      yield SlashAdmin::Engine.config
    end
  end
end
